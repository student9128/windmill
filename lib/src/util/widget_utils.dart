  import 'package:flutter/material.dart';
import 'package:windmill/src/util/asset_utils.dart';

Widget buildImage(String iconName,
    {bool isPNG = true, double w = 24, double h = 24}) {
  return Image.asset(
    isPNG
        ? AssetUtils.getAssetImagePNG(iconName)
        : AssetUtils.getAssetImage(iconName),
    width: w,
    height: h,
    package: 'windmill',
  );
}
