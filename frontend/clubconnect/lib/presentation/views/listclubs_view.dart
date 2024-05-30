import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/widget/cardClub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ListClubView extends ConsumerStatefulWidget {
  const ListClubView({super.key});

  @override
  ListClubViewState createState() => ListClubViewState();
}

class ListClubViewState extends ConsumerState<ListClubView> {
  late Future<List<Club>?> futureClubs;
  List<Club> clubs = [];
  @override
  void initState() {
    print("Entree");
    futureClubs = ref
        .read(clubConnectProvider)
        .getClubsUser(ref.read(authProvider).id!)
        .then((value) => clubs = value!);

    super.initState();
  }

  Future<void> getClubsUser() async {
    final response = await ref
        .read(clubConnectProvider)
        .getClubsUser(ref.read(authProvider).id!);
    setState(() {
      clubs = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    var decoration = BoxDecoration(
      color: AppTheme().getTheme().colorScheme.onPrimary,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, 4), // changes position of shadow
        ),
      ],
    );
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 20, bottom: 10, right: 20),
          decoration: decoration,
          child: SafeArea(
            child: Row(
              children: [
                Text('Mis Clubes',
                    style: AppTheme().getTheme().textTheme.titleMedium),
                Spacer(),
                IconButton.filled(
                    onPressed: () {
                      context.go('/home/0/newClub');
                    },
                    icon: Icon(Icons.add)),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: futureClubs,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('none');
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                  return Text('active');
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (clubs.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await getClubsUser();
                        },
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No tienes clubes',
                                    style: AppTheme()
                                        .getTheme()
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await getClubsUser();
                        },
                        child: ListView.builder(
                          itemCount: clubs.length,
                          padding: EdgeInsets.only(top: 0),
                          itemBuilder: (context, index) {
                            return CardClub(club: clubs[index]);
                            //return ClubCard(
                            //  club: clubs[index],
                            //  onPressed: () => context.go('/movie/${clubs[index].id}'),
                          },
                        ),
                      );
                    }
                  }
              }
            },
          ),
        ),
      ],
    );
  }
}
