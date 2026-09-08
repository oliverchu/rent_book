import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/models/bill.dart';
import '../../../domain/models/currency.dart';
import '../../../domain/models/tenant.dart';
import '../../core/bill_card.dart';
import '../../core/currency_scope.dart';
import '../../core/format.dart';
import '../../router/app_router.dart';

/// 账单预览页：把账单卡片渲染成图片并分享（微信收租）。
class BillShareView extends StatefulWidget {
  const BillShareView({
    super.key,
    required this.bill,
    required this.tenant,
  });

  final Bill bill;
  final Tenant tenant;

  @override
  State<BillShareView> createState() => _BillShareViewState();
}

class _BillShareViewState extends State<BillShareView> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareImage() async {
    if (_sharing) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final String localeName = Localizations.localeOf(context).toString();
    setState(() => _sharing = true);
    try {
      final BuildContext? boundaryContext = _boundaryKey.currentContext;
      if (boundaryContext == null) {
        throw StateError('账单尚未渲染完成');
      }
      final RenderRepaintBoundary boundary =
          boundaryContext.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image =
          await boundary.toImage(pixelRatio: 3); // 约 1080px 宽，微信里清晰
      final ByteData? data =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('生成图片失败');
      }
      final Directory dir = await getTemporaryDirectory();
      final String safeRoom =
          widget.tenant.room.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
      final File file = File(
          '${dir.path}/${l10n.billShareFilePrefix}_${safeRoom}_${widget.bill.year}-${widget.bill.month}.png');
      await file.writeAsBytes(data.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          title: l10n.billShareTitle(widget.tenant.room),
          text: l10n.billShareText(
            widget.tenant.room,
            widget.tenant.name,
            monthLabel(widget.bill.year, widget.bill.month, localeName),
            formatMoney(widget.bill.total, currency),
          ),
          files: <XFile>[XFile(file.path)],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.billShareFailed('$e'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.billShareViewTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.billShareEditTooltip,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushReplacement(
              AppRoutes.bill(
                widget.tenant.id,
                widget.bill.year,
                widget.bill.month,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF07C160), // 微信绿
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _sharing ? null : _shareImage,
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.share_outlined),
            label: Text(_sharing
                ? l10n.billShareGenerating
                : l10n.billShareSubmit),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFEDEDED),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: RepaintBoundary(
            key: _boundaryKey,
            child: BillCard(bill: widget.bill, tenant: widget.tenant),
          ),
        ),
      ),
    );
  }
}
