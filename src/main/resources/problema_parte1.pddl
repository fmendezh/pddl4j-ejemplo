

; Definicion del problema:
;  - En una ciudad existen las siguientes tipos de localizacion: puerto (P), almacen (A) ciudad ( C ) y fabrica (F1 y F2). 
;  - En el puerto hay contenedores que hay que procesar. 
;  - En las fabricas se procesan los contenedores. Una vez procesados, los contenedores deben llevarse al almacen. 
;  - Desde el almacen, los contenedores ya procesados se envian a su destino (se pueden hacer desaparecer). 
;  - Es posible descargar en el almacen los contenedores de material sin procesar, para usarlo como almacenamiento temporal.
;  - Para transportar los contenedores existe un tren que puede cargar un numero limitado de contenedores; puede cargarlos o descargarlos desde o hacia algunas de las localizaciones.
;  - Ademas, el tren puede mover utilizando una via que comunica las localizaciones. 
;  - Las localizaciones estan conectadas por la via del tren en un anillo (A-P-C-F2-F1-A). 
;  - Hay un unico tren, que empieza en P y puede moverse por la via en ambas direcciones.
(define (problem rutas_1)
    (:domain logistica-contendores)
    (:objects
        P C A F1 F2 - localizacion ; localizaciones P = puerto, C = Ciudad, F1 = Fabrica 1, F2 = Fabrica 2, A = Almacen        
        T - tren ; un unico tren
        CONT1 CONT2 CONT3 CONT4 CONT5 CONT6 CONT7 CONT8 - contenedor ; 8 contenedores
                
        ; capacidades
        TN0 TN1 TN2 TN3 TN4 - numero ; contador de capacidad del tren     
        AN0 AN1 AN2 AN3  - numero ; contador de capacidad del almacen
        F1N0 F1N1 F1N2 F1N3  - numero ; contador de capacidad de la fabrica 1
        F2N0 F2N1 - numero ; contador de capacidad de la fabrica 2  
    )

    (:init
        ; A y P conectan en ambos sentidos
        (contectada P A)
        (contectada A P)

        ; P y C conectan en ambos sentidos
        (contectada P C)
        (contectada C P)

        ; C y F2 conectan en ambos sentidos
        (contectada C F2)
        (contectada F2 C)

        ; F2 y F1 conectan en ambos sentidos
        (contectada F2 F1)
        (contectada F1 F2)

        ; F1 y A conectan en ambos sentidos
        (contectada F1 A)
        (contectada A F1)        

        ; tren inicia en el puerto    
        (en T P)
        
        ; los contenedores estan incialmente en el puerto
        (en CONT1 P)
        (en CONT2 P)
        (en CONT3 P)
        (en CONT4 P)
        (en CONT5 P)
        (en CONT6 P)
        (en CONT7 P)
        (en CONT8 P)

        ; define los tipos de cada localizacion
        (es_almacen A)
        (es_fabrica F1)
        (es_fabrica F2)
        (es_ciudad C)
        (es_puerto P)         
                

        ; contadores y capacidad del tren
        (capacidad T TN4)        
        (siguiente TN0 TN1)
        (siguiente TN1 TN2)
        (siguiente TN2 TN3)
        (siguiente TN3 TN4)

        ; contadores y capacidad del alamacen
        (capacidad A AN3)
        (siguiente AN0 AN1)
        (siguiente AN1 AN2)
        (siguiente AN2 AN3)

        ; contadores y capacidad de la fabrica 1
        (capacidad F1 F1N3)
        (siguiente F1N0 F1N1)
        (siguiente F1N1 F1N2)
        (siguiente F1N2 F1N3)

        ; contadores y capacidad de la fabrica 2
        (capacidad F2 F2N1)
        (siguiente F2N0 F2N1)
    )

    ; la meta es que todos los contenedores han sido enviados
    (:goal
        (and
            (enviado CONT1)
            (enviado CONT2)
            (enviado CONT3)
            (enviado CONT4)
            (enviado CONT5)
            (enviado CONT6)
            (enviado CONT7)
            (enviado CONT8)    
        )
    )
)