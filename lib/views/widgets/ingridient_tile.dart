import 'package:flutter/material.dart';
import 'package:hungry/models/core/recipe.dart';

class IngridientTile extends StatelessWidget {
  final String? name;
  final String? size;
  IngridientTile({required this.name,required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[350]!, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(name != null)
          Flexible(
            flex: 9,
            child: Text(
              name.toString(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 150 / 100),
            ),
          ),

          if(size != null)
            Flexible(
            flex: 3,
            child: Text(
              size.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'inter', color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
