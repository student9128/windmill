  import 'package:flutter/material.dart';
import 'package:windmill/src/util/asset_utils.dart';

Widget buildImage(String iconName,
    {bool isPNG = true,
    double width = 22,
    double height = 22,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration}) {
  return Container(
      padding: padding ?? const EdgeInsets.all(5),
      margin: margin,
      color: color,
      decoration: decoration,
      child: Image.asset(
        isPNG
            ? AssetUtils.getAssetImagePNG(iconName)
            : AssetUtils.getAssetImage(iconName),
        width: width,
        height: height,
        package: 'windmill',
      ));
}
