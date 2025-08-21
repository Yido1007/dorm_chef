import 'package:dorm_chef/model/recipes.dart';

class Scored {
  final Recipe recipe;
  final int have;
  final int total;
  final double ratio;
  Scored({
    required this.recipe,
    required this.have,
    required this.total,
    required this.ratio,
  });
}
