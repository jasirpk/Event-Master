import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/dashboard/favorite.dart';
import 'package:event_master/presentation/components/dashboard/home.dart';
import 'package:event_master/presentation/components/dashboard/search.dart';
import 'package:event_master/presentation/components/dashboard/events.dart';
import 'package:event_master/presentation/pages/dashboard/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final List<Widget> pages = [
    HomePage(),
    SearchPage(),
    EventPage(),
    FavoritePage(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          int currentIndex = 0;
          if (state is TabState) {
            currentIndex = state.index;
          } else if (state is DashboardInitial) {
            currentIndex = state.selectedIndex;
          }

          return CurvedNavigationBar(
            backgroundColor: myColor,
            color: Colors.black,
            animationDuration: Duration(milliseconds: 200),
            index: currentIndex,
            items: <Widget>[
              Icon(Icons.home, size: 20, color: Colors.white),
              Icon(Icons.search, size: 20, color: Colors.white),
              Icon(Icons.receipt, size: 20, color: Colors.white),
              Icon(Icons.favorite, size: 20, color: Colors.white),
              Icon(Icons.settings, size: 20, color: Colors.white),
            ],
            onTap: (index) {
              context.read<DashboardBloc>().add(TabChanged(index));
            },
          );
        },
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is TabState) {
            return IndexedStack(
              index: state.index,
              children: pages,
            );
          }
          return pages[0];
        },
      ),
    );
  }
}
