import 'package:flutter/material.dart';
import 'home_page.dart';
import 'contacts.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('eCEP',
            style: TextStyle(
                color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.indigo),
      ),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMainContent(),
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Accueil', HomePage()),
          _buildDrawerItem(context, Icons.info, 'À Propos', AboutPage()),
          _buildDrawerItem(context, Icons.contact_mail, 'Contact', ContactPage()),
        ],
      ),
    );
  }
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

Widget _buildMissionCard(IconData icon, String title, String description) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.indigo),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade100, Colors.indigo.shade200],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Notre Mission',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildMissionCard(Icons.adjust_sharp, 'Notre Vision',
                    "Révolutionner l'apprentissage des élèves de CM2 en proposant une plateforme numérique interactive et engageante."),
                _buildMissionCard(Icons.book_online, 'Nos Objectifs',
                    "Faciliter la préparation au Certificat d'Études Primaires avec des ressources pédagogiques de qualité."),
                _buildMissionCard(Icons.school, 'Notre Engagement',
                    'Accompagner chaque élève dans sa progression académique avec des outils personnalisés et motivants.'),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qui Sommes-Nous ?',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "eCEP est une solution éducative innovante conçue pour les élèves de CM2. Notre plateforme offre des cours interactifs, des exercices personnalisés et un suivi pédagogique complet pour préparer au mieux le Certificat d'Études Primaires.",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.indigo.shade800,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section des liens rapides
          Wrap(
            spacing: 30,
            runSpacing: 20,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              _buildFooterColumn('Navigation', [
                'Accueil',
                'À propos',
                'Contact',
                'FAQ'
              ]),
              _buildFooterColumn('Ressources', [
                'Cours',
                'Exercices',
                'Examens blancs',
                'Tutoriels'
              ]),
              _buildFooterColumn('Aide', [
                'Centre d\'aide',
                'Support technique',
                'Guide utilisation',
                'Mentions légales'
              ]),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Section des réseaux sociaux
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialButton(Icons.facebook, 'Facebook'),
              _buildSocialButton(Icons.messenger_outline, 'Messenger'),
              _buildSocialButton(Icons.whatshot, 'WhatsApp'),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Section contact et copyright
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Contactez-nous : support@ecep.edu",
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 8),
              Text(
                "Tél : +221 XX XXX XX XX",
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                "© 2025 eCEP - Préparation Certificat d'Études Primaires",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Tous droits réservés",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Nouveaux widgets helper pour le footer
  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () {},
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String platform) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              platform,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}