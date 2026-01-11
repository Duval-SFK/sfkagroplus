import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: AuthService.getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur lors du chargement du profil",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("Aucune donnée utilisateur trouvée."));
            }

            final data = snapshot.data!;
            // Utilise des clés cohérentes selon ton enregistrement (ex: 'name', 'email', 'location')
            final String name = (data['nom'] ?? 'Utilisateur') as String;
            final String email = (data['email'] ?? '') as String;
            final String location =
                (data['lokation'] ?? 'Non défini') as String;
            final String? photoUrl = data['photoUrl'] as String?;

            // Calculer initiales si pas de photo
            String initials = '';
            if (name.trim().isNotEmpty) {
              final parts = name.trim().split(' ');
              initials = parts
                  .take(2)
                  .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                  .join();
            }

            return Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // Nom
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Email
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),

                // Localisation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(location),
                  ],
                ),

                const SizedBox(height: 20),

                // Options
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text("Modifier profil"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // rediriger vers ta page d'édition (à créer)
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text("Historique"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/history');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text("Paramètres"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          "Se déconnecter",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          await AuthService.signOut();
                          if (!mounted) return;
                          // enlever toute la pile et revenir à la page de login
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
