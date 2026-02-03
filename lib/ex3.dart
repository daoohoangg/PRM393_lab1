import 'dart:async';


void main() {
  print('A: sync start');

  scheduleMicrotask(() => print('B: microtask 1'));

  Future(() => print('C: future event 1'));
  Future(() => print('D: future event 2'));

  scheduleMicrotask(() => print('E: microtask 2'));

  print('F: sync end');
}