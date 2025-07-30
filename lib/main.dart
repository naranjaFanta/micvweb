import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/foundation.dart'
   // show kIsWeb; // por si más adelante querés usar condicionales


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(
      '6LdR1JMrAAAAADewJHo_pDvzUaZpxZjuMMGlgY6Y',
    ),
  );
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  runApp(const CvApp());
}

class CvApp extends StatelessWidget {
  const CvApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eduardo Víctor Giménez • CV',
      theme: baseTheme,
      home: const CvHome(),
    );
  }
}

enum Section { home, about, skills, experience, projects, contact }

class CvHome extends StatefulWidget {
  const CvHome({super.key});
  @override
  State<CvHome> createState() => _CvHomeState();
}

class _CvHomeState extends State<CvHome> {
  final _scrollController = ScrollController();
  final _keys = {for (final s in Section.values) s: GlobalKey()};

  void _scrollTo(Section s) {
    final ctx = _keys[s]!.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildNavButtons(bool dense) {
    TextStyle? style = dense ? const TextStyle(fontSize: 13) : null;
    return [
      TextButton(
        onPressed: () => _scrollTo(Section.home),
        child: Text('Inicio', style: style),
      ),
      TextButton(
        onPressed: () => _scrollTo(Section.about),
        child: Text('Sobre mí', style: style),
      ),
      TextButton(
        onPressed: () => _scrollTo(Section.skills),
        child: Text('Habilidades', style: style),
      ),
      TextButton(
        onPressed: () => _scrollTo(Section.experience),
        child: Text('Experiencia', style: style),
      ),
      TextButton(
        onPressed: () => _scrollTo(Section.projects),
        child: Text('Proyectos', style: style),
      ),
      FilledButton(
        onPressed: () => _scrollTo(Section.contact),
        child: Text('Contacto', style: style),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;

    final content = SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          _Section(key: _keys[Section.home], child: const _HeroHeader()),
          _Section(key: _keys[Section.about], child: const _About()),
          _Section(key: _keys[Section.skills], child: const _Skills()),
          _Section(key: _keys[Section.experience], child: const _Experience()),
          _Section(key: _keys[Section.projects], child: const _Projects()),
          _Section(key: _keys[Section.contact], child: _Contact()),
          const SizedBox(height: 24),
          const _Footer(),
        ],
      ),
    );

    if (!isWide) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Eduardo Víctor Giménez'),
          actions: _buildNavButtons(true),
        ),
        body: content,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                label: Text('Sobre mí'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bolt_outlined),
                label: Text('Habilidades'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work_outline),
                label: Text('Experiencia'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder_open),
                label: Text('Proyectos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.mail_outline),
                label: Text('Contacto'),
              ),
            ],
            onDestinationSelected: (i) => _scrollTo(Section.values[i]),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildNavButtons(false),
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      constraints: const BoxConstraints(maxWidth: 1200),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: child,
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headline = Theme.of(
      context,
    ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundImage: const AssetImage('assets/images/profile.jpg'),
          backgroundColor: cs.primaryContainer,
        ),
        const SizedBox(height: 16),
        Text(
          'EDUARDO VÍCTOR GIMÉNEZ',
          style: headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Analista de Sistemas • Analista Programador',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => _launchUrl('https://github.com/naranjaFanta'),
              icon: const Icon(Icons.code),
              label: const Text('GitHub'),
            ),
          ],
        ),
      ],
    );
  }
}

class _About extends StatelessWidget {
  const _About();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _H2('Sobre mí'),
        SizedBox(height: 12),
        Text(
          'Soy Analista de Sistemas con foco en Flutter para web y Android. Me gusta convertir requerimientos '
          'en interfaces limpias y rápidas, integrando Firebase y bases SQL cuando hace falta. Trabajo ordenado '
          'con Git/GitHub, buenas prácticas y pruebas básicas. Busco mi primera experiencia profesional para '
          'aportar valor desde el día uno.'
          ' Estoy abierto a aprender nuevas tecnologias que se adapten a lo que el cliente necesite.',
        ),
      ],
    );
  }
}

class _Skills extends StatelessWidget {
  const _Skills();
  @override
  Widget build(BuildContext context) {
    final skills = const [
      'Flutter (Web & Android)',
      'Dart',
      'Firebase (Auth, Firestore, Storage, Hosting)',
      'Java (Eclipse)',
      'SQL (modelado y consultas)',
      'Principios OOP y buenas prácticas',
      'Pruebas y debugging básico',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _H2('Habilidades'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map(
                (s) => Chip(
                  label: Text(s),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Experience extends StatelessWidget {
  const _Experience();
  @override
  Widget build(BuildContext context) {
    final items = [
      const _ExpItem(
        title: 'Proyectos académicos y personales',
        period: '2023 — Actualidad',
        bullets: [
          'Flutter (web y Android) con diseño responsive.',
          'Integraciones con Firebase: Auth, Firestore, Storage y Hosting.',
          'Java (POO) con Eclipse para proyectos académicos.',
          'Flujo con Git/GitHub (commits claros y versionado).',
        ],
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _H2('Experiencia'),
        const SizedBox(height: 12),
        Column(children: items),
      ],
    );
  }
}

class _ExpItem extends StatelessWidget {
  final String title;
  final String period;
  final List<String> bullets;
  const _ExpItem({
    required this.title,
    required this.period,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(period, style: TextStyle(color: cs.outline)),
            const SizedBox(height: 8),
            ...bullets.map(
              (b) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(b)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Projects extends StatelessWidget {
  const _Projects();
  @override
  Widget build(BuildContext context) {
    final projects = [
      const _ProjectCard(
        title: 'AI PC Builder',
        desc: 'Asistente para armar PCs con sugerencias y compatibilidades.',
        link: 'https://iapcbuilder.web.app/',
      ),
      const _ProjectCard(
        title: 'Mi CV Web',
        desc: 'Este sitio, hecho con Flutter Web y desplegado en GitHub Pages.',
        link: 'https://github.com/naranjaFanta/micvweb',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _H2('Proyectos'),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: projects),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String title;
  final String desc;
  final String link;
  const _ProjectCard({
    required this.title,
    required this.desc,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width >= 980 ? 460.0 : double.infinity;

    return SizedBox(
      width: cardWidth,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(desc),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _launchUrl(link),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contact extends StatefulWidget {
  _Contact({super.key});

  @override
  State<_Contact> createState() => _ContactState();
}

class _ContactState extends State<_Contact> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

 Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _sending = true);
  try {
    final data = {
      'name': _nameCtrl.text.trim(),
      'company': _companyCtrl.text.trim(),
      'email': _emailCtrl.text.trim().toLowerCase(),
      'phone': _phoneCtrl.text.trim(),
      'message': _messageCtrl.text.trim(),
      'source': 'cv-web',          // útil para segmentar
      'status': 'new',             // para tu bandeja (new|replied|archived)
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('inquiries').add(data);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Gracias! Tu consulta fue enviada.')),
    );
    _formKey.currentState!.reset();
    _nameCtrl.clear();
    _companyCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _messageCtrl.clear();
  } on FirebaseException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo enviar la consulta: ${e.message ?? e.code}')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo enviar la consulta: $e')),
    );
  } finally {
    if (mounted) setState(() => _sending = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _H2('Contacto'),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 320,
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre y apellido',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresá tu nombre'
                      : null,
                ),
              ),
              SizedBox(
                width: 320,
                child: TextFormField(
                  controller: _companyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Empresa (opcional)',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: 320,
                child: TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email de contacto',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final email = v?.trim() ?? '';
                    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
                    return ok ? null : 'Ingresá un email válido';
                  },
                ),
              ),
              SizedBox(
                width: 320,
                child: TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: 660,
                child: TextFormField(
                  controller: _messageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Consulta / Descripción',
                  ),
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Contame un poco más (mín. 10 caracteres)'
                      : null,
                ),
              ),
              SizedBox(
                width: 660,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _submit,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_sending ? 'Enviando...' : 'Enviar consulta'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        '© ${DateTime.now().year} Eduardo Víctor Giménez — Hecho con Flutter',
        style: TextStyle(color: cs.outline),
      ),
    );
  }
}

class _H2 extends StatelessWidget {
  final String text;
  const _H2(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('No se pudo abrir $url');
  }
}



//20c5d70d-ca10-4e65-8244-591304a26a28