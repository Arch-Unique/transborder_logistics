import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../global/model/barrel.dart';
import '../utils_barrel.dart';

enum PasswordStrength {
  normal,
  weak,
  okay,
  strong,
}

enum FPL {
  email(TextInputType.emailAddress),
  number(TextInputType.number),
  text(TextInputType.text),
  password(TextInputType.visiblePassword),
  multi(TextInputType.multiline, maxLength: 1000, maxLines: 5),
  phone(TextInputType.phone),
  money(TextInputType.number),

  //card details
  cvv(TextInputType.number, maxLength: 4),
  cardNo(TextInputType.number, maxLength: 20),
  dateExpiry(TextInputType.datetime, maxLength: 5);

  final TextInputType textType;
  final int? maxLength, maxLines;

  const FPL(this.textType, {this.maxLength, this.maxLines = 1});
}

enum AuthMode {
  login("Login", "Enter your personal details below to proceed", "Don't have an account? ",
      "Register here!", "Or Log in with"),
  register("Create An Account", "Enter your personal details below to proceed",
      "Already have an account? ", "Login!", "Or sign up with");

  final String title, desc, after, afterAction, thirdparty;
  const AuthMode(
      this.title, this.desc, this.after, this.afterAction, this.thirdparty);
}

enum ErrorTypes {
  noInternet(Icons.wifi_tethering_off_rounded, "No Internet Connection",
      "Please check your internet connection and try again"),
  noPatient(Icons.pregnant_woman_rounded, "No Patient Found",
      "Oops. no patients found. Please contact support for help"),
  noDonation(Iconsax.empty_wallet_outline, "No Donation Found",
      "You haven't made any donations yet. Why not make a difference today? "),
  serverFailure(Icons.power_off_rounded, "Server Failure",
      "Something bad happened. Please try again later");

  final String title, desc;
  final dynamic icon;
  const ErrorTypes(this.icon, this.title, this.desc);
}

enum DashboardMode {
  dashboard("Dashboard",HugeIcons.strokeRoundedDashboardSquare02,["All"]),
  trips("Trips",HugeIcons.strokeRoundedBus03,["All","Ongoing","Finished"]),
  users("Users",HugeIcons.strokeRoundedUser,["All","Driver","Admin","Operator"]),
  drivers("Drivers",HugeIcons.strokeRoundedUserMultiple02,["All","Available","Busy","Inactive"]),
  vehicles("Vehicles",HugeIcons.strokeRoundedCar01,["All"]),
  facilities("Facilities",HugeIcons.strokeRoundedBuilding05,["All"]),
  pickups("Loading Points",HugeIcons.strokeRoundedShippingLoading,["All"]),
  location("Location",HugeIcons.strokeRoundedLocation05,["All"]);
  

  final String name;
  final dynamic icon;
  final List<String> filters;
  const DashboardMode(this.name,this.icon,this.filters);
}
