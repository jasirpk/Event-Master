import 'package:flutter/material.dart';

class SilverAppBarWidget extends StatelessWidget {
  const SilverAppBarWidget({
    Key? key,
    required this.screenHeight,
  }) : super(key: key);

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/cover_img_2.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 70.0,
                  left: 16.0,
                  right: 16.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundImage:
                          AssetImage('assets/images/download.jpeg'),
                    ),
                    title: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Text(
                        'Hey! PK Events',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'JacquesFracois',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      'Welcome to Admin Master',
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'JacquesFracois',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Transform.rotate(
              angle: 5.5,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.send_sharp),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
            ),
            SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              height: 60,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
        // Additional SliverList for the body content
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              title: Text('Item #$index'),
            ),
            childCount: 20,
          ),
        ),
      ],
    );
  }
}
