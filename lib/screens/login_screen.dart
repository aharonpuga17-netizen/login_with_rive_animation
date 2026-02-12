import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Control para mostrar/ocultar la contraseña
  bool _obscureText = true;

  //Crear el cerebro de la animación
  StateMachineController? _controller;
  //SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMIBool? _trigSuccess;
  SMIBool? _trigFail;

  @override
  Widget build(BuildContext context) {
    // Para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        // Evita que el contenido se superponga con el notch
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width:size.width,
                height:200,
                child: RiveAnimation.asset(
                  'assets/animated_login_bear.riv',
                  stateMachines: ['Login Machine'],
                  //Al inciar la anaimación
                  onInit: (artboard){
                    _controller = StateMachineController.fromArtboard(artboard, 
                    'Login Machine',
                    );

                    //Verifica que inició bien
                    if (_controller == null);
                    //Agrega el controlador al tablero/escenario
                    artboard.addController(_controller!);
                    //Vincular variables
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('trigSuccess');
                    _trigFail = _controller!.findSMI('trigFail');
                  },
                  )
                ),
              // Para separación
              const SizedBox(height: 10),

              TextField(
                onChanged: (value){
                  if(_isHandsUp !=null){
                    //No tapes los ojos al ver email
                    _isHandsUp!.change(false);
                  }
                  //Si isChecking es nullo
                  if(_isChecking == null)return;
                  //Activar el modo chismoso
                  _isChecking!.change(true);
                },
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    // Para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                 onChanged: (value){
                  if(_isChecking !=null){
                    //No quiero modo chismoso
                    _isChecking!.change(false);
                  }
                  //Si HandsUp es nulo
                  if(_isHandsUp == null)return;
                  //levanta las manos
                  _isHandsUp!.change(true);
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      //Refresca el icono
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
