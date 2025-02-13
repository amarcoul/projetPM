import 'package:flutter/material.dart';
import 'about.dart';
import 'contacts.dart';
import 'screens/eleve/elevelogin.dart';
import 'screens/parent/parentlogin.dart';
import 'screens/enseignant/enseignantlogin.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('eCEP',
            style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
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
                      child: _buildMainContent(context),
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

  // MENU LATÉRAL (Drawer)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Menu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Accueil', HomePage()),
          _buildDrawerItem(context, Icons.info, 'À Propos', AboutPage()),
          _buildDrawerItem(
              context, Icons.contact_mail, 'Contact', ContactPage()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  // CONTENU PRINCIPAL
  Widget _buildMainContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.indigo.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                Text("Préparez-vous pour le Certificat d'Études Primaires",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800)),
                SizedBox(height: 16),
                Text(
                    'Une plateforme interactive pour apprendre, progresser et réussir !',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          ),
          _buildFeatureCards(),
          _buildLoginOptions(context),
        ],
      ),
    );
  }

  // CARTES DE FONCTIONNALITÉS
  Widget _buildFeatureCards() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _buildFeatureCard(Icons.book_online, 'Cours Interactifs',
              'Apprenez avec des contenus multimédia'),
          _buildFeatureCard(Icons.assessment, 'Examens Blancs',
              'Entraînez-vous aux épreuves'),
          _buildFeatureCard(
              Icons.school, 'Suivi Personnalisé', 'Progressez à votre rythme'),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 50, color: Colors.indigo),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  // OPTIONS DE CONNEXION
  Widget _buildLoginOptions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Inscrivez-vous',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800)),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildUserTypeButton(context, 'Élève', Colors.blue,
                  Icons.person_add, StudentLoginPage()),
              _buildUserTypeButton(context, 'Parent', Colors.green,
                  Icons.person, ParentLoginPage()),
              _buildUserTypeButton(context, 'Enseignant', Colors.orange,
                  Icons.school, TeacherLoginPage()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeButton(BuildContext context, String label, Color color,
      IconData icon, Widget targetPage) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context, // Assurez-vous que le contexte est bien passé ici
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      icon: Icon(icon, size: 20),
      label: Text(label, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // PIED DE PAGE
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
              _buildFooterColumn(
                  'Navigation', ['Accueil', 'À propos', 'Contact', 'FAQ']),
              _buildFooterColumn('Ressources',
                  ['Cours', 'Exercices', 'Examens blancs', 'Tutoriels']),
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

  // Helper pour les colonnes du footer
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

  // Helper pour les boutons de réseaux sociaux
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
