import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/useful/size_config.dart';

class OWALogo extends StatelessWidget {
  final Color? color;
  const OWALogo({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    // Definimos el color por defecto para no repetirlo tantas veces
    final iconColor = color ?? const Color.fromRGBO(247, 240, 233, 1);
    
    // Altura base responsiva para las letras
    final double letterHeight = MediaQuery.of(context).size.width > 1440 
        ? SizeConfig.w(30) 
        : SizeConfig.w(18); // Le damos un poquito más de holgura

    return Row(
      mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el ancho si no es necesario
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Letra O
        SizedBox(
          width: SizeConfig.w(15.15),
          height: letterHeight,
          child: SvgPicture.asset(
            'assets/logo/o.svg',
            fit: BoxFit.contain, // Contain asegura que NUNCA se recorte nada
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        
        SizedBox(width: SizeConfig.w(28.0)), // Espaciado ajustado
        
        // Letra W
        SizedBox(
          width: SizeConfig.w(21.53),
          height: letterHeight,
          child: SvgPicture.asset(
            'assets/logo/w.svg',
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        
        SizedBox(width: SizeConfig.w(28.0)), // Espaciado ajustado
        
        // Letra A
        SizedBox(
          width: SizeConfig.w(14.44),
          height: letterHeight,
          child: SvgPicture.asset(
            'assets/logo/a.svg',
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),

        // Círculo de grado (°)
        // Sin espaciado extra aquí para que quede pegado a la 'A' como en la imagen
        SizedBox(
          width: SizeConfig.w(4.31),
          // El círculo suele ser más pequeño, lo dejamos ajustarse a su ancho
          child: SvgPicture.asset(
            'assets/logo/circle.svg',
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}