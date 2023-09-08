import 'package:flutter/material.dart';

abstract class DrawingPageState {}

class DrawingPageInitialState extends DrawingPageState {}

class DrawingPageLoadingState extends DrawingPageState {}

class DrawingPageLoadedState extends DrawingPageState {
  /* final DrawingPageResponseModel otpModel;
  DrawingPageLoadedState(this.otpModel); */
}

class DrawingPageErrorState extends DrawingPageState {
  final String error;
  DrawingPageErrorState(this.error);
}
