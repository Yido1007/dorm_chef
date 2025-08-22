import 'package:dorm_chef/model/recipes.dart';

class Scored {
  final Recipe r;
  final int have;
  final int total;
  final double ratio;
  Scored({
    required this.r,
    required this.have,
    required this.total,
    required this.ratio,
  });
}
