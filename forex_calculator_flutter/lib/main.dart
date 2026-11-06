import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ForexCalculatorApp());

class ForexCalculatorApp extends StatelessWidget {
  const ForexCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B1220);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ماشین حساب فارکس',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF28C997),
          brightness: Brightness.dark,
          surface: const Color(0xFF151F30),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151F30),
          labelStyle: const TextStyle(color: Color(0xFFAFBDD0)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF26354B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF28C997), width: 1.5),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: CalculatorPage(),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _balance = TextEditingController(text: '1000');
  final _risk = TextEditingController(text: '1');
  final _stopLoss = TextEditingController(text: '20');
  final _pipValue = TextEditingController(text: '10');

  double? _riskMoney;
  double? _lots;
  double? _units;
  String? _error;

  double? _number(TextEditingController c) {
    return double.tryParse(c.text.trim().replaceAll(',', '.'));
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final balance = _number(_balance);
    final risk = _number(_risk);
    final stop = _number(_stopLoss);
    final pipValue = _number(_pipValue);

    if (balance == null || risk == null || stop == null || pipValue == null ||
        balance <= 0 || risk <= 0 || risk > 100 || stop <= 0 || pipValue <= 0) {
      setState(() {
        _error = 'لطفاً همه مقادیر را درست وارد کن. ریسک باید بین ۰ تا ۱۰۰ باشد.';
        _riskMoney = _lots = _units = null;
      });
      return;
    }

    final riskMoney = balance * risk / 100;
    final lots = riskMoney / (stop * pipValue);
    setState(() {
      _error = null;
      _riskMoney = riskMoney;
      _lots = lots;
      _units = lots * 100000;
    });
  }

  void _clear() {
    _balance.text = '';
    _risk.text = '';
    _stopLoss.text = '';
    _pipValue.text = '10';
    setState(() {
      _error = null;
      _riskMoney = _lots = _units = null;
    });
  }

  @override
  void dispose() {
    _balance.dispose();
    _risk.dispose();
    _stopLoss.dispose();
    _pipValue.dispose();
    super.dispose();
  }

  Widget _field(String label, TextEditingController controller,
      {String? suffix, String? hint}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ),
      onSubmitted: (_) => _calculate(),
    );
  }

  Widget _resultTile(String title, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF123B36) : const Color(0xFF101A29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? const Color(0xFF28C997) : const Color(0xFF26354B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFAFBDD0), fontSize: 12)),
          const SizedBox(height: 7),
          Text(value, style: TextStyle(
            fontSize: highlight ? 23 : 18,
            fontWeight: FontWeight.bold,
            color: highlight ? const Color(0xFF55E0B3) : Colors.white,
          )),
        ],
      ),
    );
  }

  String _fmt(double value, int digits) => value.toStringAsFixed(digits);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ماشین حساب فارکس', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B1220),
        actions: [
          IconButton(
            tooltip: 'پاک کردن',
            onPressed: _clear,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF173B42), Color(0xFF17243A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مدیریت ریسک و محاسبه حجم معامله',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('موجودی، درصد ریسک و حد ضرر را وارد کن تا حجم لات پیشنهادی محاسبه شود.',
                    style: TextStyle(color: Color(0xFFD0DCE8), height: 1.7)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('اطلاعات معامله', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _field('موجودی حساب', _balance, suffix: 'USD'),
            const SizedBox(height: 12),
            _field('ریسک هر معامله', _risk, suffix: '%'),
            const SizedBox(height: 12),
            _field('حد ضرر', _stopLoss, suffix: 'پیپ'),
            const SizedBox(height: 12),
            _field('ارزش هر پیپ برای ۱ لات استاندارد', _pipValue, suffix: 'USD',
              hint: 'مثلاً برای EUR/USD معمولاً 10'),
            const SizedBox(height: 8),
            const Text(
              'نکته: مقدار ارزش پیپ را متناسب با جفت‌ارز و ارز پایه حساب خودت وارد کن. '
              'عدد پیش‌فرض ۱۰ دلار برای بسیاری از جفت‌ارزهای اصلی با حساب دلاری تقریبی است.',
              style: TextStyle(color: Color(0xFF91A2B8), fontSize: 12, height: 1.7),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('محاسبه حجم معامله', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF28C997),
                  foregroundColor: const Color(0xFF071A17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(color: Color(0xFFFF8585))),
            ],
            if (_lots != null) ...[
              const SizedBox(height: 24),
              const Text('نتیجه محاسبه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _resultTile('حجم پیشنهادی معامله', '${_fmt(_lots!, 3)} لات', highlight: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _resultTile('مقدار ریسک', '${_fmt(_riskMoney!, 2)} USD')),
                  const SizedBox(width: 10),
                  Expanded(child: _resultTile('حجم واحد', '${_fmt(_units!, 0)} Units')),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF252D3A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'این نتیجه بر اساس ارزش پیپی است که وارد کرده‌ای و شامل کمیسیون، اسپرد، اسلیپیج و تبدیل نرخ ارز نیست. '
                  'قبل از ثبت سفارش، حجم را با مشخصات بروکر تطبیق بده.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFCFD8E5), height: 1.7),
                ),
              ),
            ],
            const SizedBox(height: 28),
            const Center(
              child: Text('Forex Calculator • نسخه 1.0.0',
                style: TextStyle(color: Color(0xFF718198), fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
