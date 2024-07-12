import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/dashboard/favorite.dart';
import 'package:event_master/presentation/components/dashboard/home.dart';
import 'package:event_master/presentation/components/dashboard/search.dart';
import 'package:event_master/presentation/components/dashboard/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final List<Widget> pages = [
    HomePage(),
    SearchPage(),
    VendorPage(),
    FavoritePage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: myColor,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 400),
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.search, size: 30, color: Colors.white),
          Icon(Icons.receipt, size: 30, color: Colors.white),
          Icon(Icons.favorite, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          context.read<DashboardBloc>().add(TabChanged(index));
        },
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial) {
            return pages[0];
          } else if (state is TabState) {
            return IndexedStack(
              index: state.index,
              children: pages,
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
