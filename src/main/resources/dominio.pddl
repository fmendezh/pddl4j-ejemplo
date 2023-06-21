; Elementos claves del problema:
;  - Hay un unico tren, que empieza en P (puerto) y puede moverse por la via en ambas direcciones 
;  - El tren puede realizar las acciones: 
;    * mover: a una localizacion conectada, en direcciones opuestas y acciones sucesivas
;    * cargar: un contenedor en una fabrica o almacen siempre que no se exceda la capacidad del tren
;    * cargar_en_puerto: un contenedor puerto, el puerto tiene capacidad ilimitada, por lo tanto las capacidades son ignoradas
;    * descargar: un contenedor en una fabrica o almancen siempre que no se exceda la capacidad de la localizacion
;  - Los contenedores que llegan a una fabrica pasan a estado procesado
;  - Los contenedores procesados que llegan a un almacen, son enviaodos y quedan fuera del sistema
; 
; El manejo de capacidades se baso en: https://github.com/potassco/pddl-instances/blob/master/ipc-2011/domains/transport-sequential-optimal/domain.pddl 
(define (domain logistica-contendores)
    
    (:requirements :typing :negative-preconditions :strips :conditional-effects)

    (:types 
        tren - object
        contenedor - object
        localizacion - object ; puerto, fabrica o almacen
        numero - object ; usado para llevar conteos de capacidades
    )

    (:predicates
        ; esta x en y
        (en ?x - object ?y - localizacion) 

        ; estan las localizaciones  l1 y l2 conectados, se puede ir de una a la otra
        (contectada ?localizacion1 - localizacion ?localizacion2 - localizacion) 
        
        ; esta el contendor c cargado en el tren t
        (cargado ?c - contenedor ?tren - tren)

        ; un contenedor ha sido procesado en una fabrica
        (procesado ?c - contenedor)
        
        ; un contenedor ha sido enviado desde el almacen, sacado del sistema
        (enviado ?c - contenedor) 
        
        ;es la localizacion una fabrica
        (es_fabrica ?localizacion - localizacion)

        ;es la localizacion un almacen
        (es_almacen ?localizacion - localizacion) 

        ;es la localizacion una ciudad
        (es_ciudad ?localizacion - localizacion)
        
        ;es la localizacion un puerto
        (es_puerto ?localizacion - localizacion) 
        
        ; el valor v1 es el valor siguiente a v2
        (siguiente ?v1 - numero ?v2 - numero) 
        
        ;capacidad actual de una localizacion o tren
        (capacidad ?o - object ?cap - numero) 
    )

    ; Mueve el tren de una localizacion1 conectada a una localizacion2
    ; Nota: esta accion fue tomada del ejemplo visto en clase Razonamiento y Planificacion Automatica - UNIR - 2023
    (:action mover
        :parameters (?tren - tren ?localizacion1 - localizacion ?localizacion2 - localizacion)
        :precondition (and
            (en ?tren ?localizacion1) ; tren el localizacion1
            (contectada ?localizacion1 ?localizacion2) ; localizacion1 conectada con localizacion2
        )
        :effect (and
            (en ?tren ?localizacion2) ; el tren esta ahora en localizacion2
            (not (en ?tren ?localizacion1)) ; el tren ya no esta en localizacion1
        )
    )

    ; Carga el tren en el puerto, accion creada debido a que el puerto no tiene una capacidad definida 
    ; Esta accion sigue los mismos pasos de "cargar" excepto que no toma en cuenta capacidades y solo aplica para el puerto
    (:action cargar_en_puerto
        :parameters (?c - contenedor ?tren - tren ?localizacion - localizacion
                     ; contador de capacidad del tren                       
                     ?ctv1 ?ctv2 - numero)
        :precondition (and
            ; precondiciones
            (en ?c ?localizacion) ; contenedor en la localizacion
            (en ?tren ?localizacion) ; tren en la localizacion
            (not (cargado ?c ?tren)) ; no esta en el tren
            (not (enviado ?c)) ; el contenedor no ha sido enviado              
            (es_puerto ?localizacion) ; en la ciudad no se puede cargar ni descargar            

            ; capacidad actual del tren                                    
            (siguiente ?ctv1 ?ctv2) 
            (capacidad ?tren ?ctv2)           
        )
        :effect (and            
            (cargado ?c ?tren) ; el contenedor esta cargado en el tren
            (not (en ?c ?localizacion)) ; el contenedor no esta en la localizacion

            ; se decrementa la capacidad del tren           
            (capacidad ?tren ?ctv1)
            (not (capacidad ?tren ?ctv2))                                            
        )
    )

    ; el tren se carga en una localizacion que no sea puerto (ver accion cargar_en_puerto) ni ciudad
    ; se incrementan la capacidad de la localizacion y se decrementa la del tren
    (:action cargar
        :parameters (?c - contenedor ?tren - tren ?localizacion - localizacion
                    ; contador de capacidad tren                       
                    ?ctv1 ?ctv2 - numero
                    ; contador de capacidad de la localizacion                      
                    ?ctl1 ?ctl2 - numero)
        :precondition (and
            ; precondiciones
            (en ?c ?localizacion) ; contenedor en localizacion
            (en ?tren ?localizacion) ; el tren esta en la localizacion
            (not (cargado ?c ?tren)) ; el contenedor aun no esta en el tren
            (not (enviado ?c)) ; el contenedor no ha sido enviado  
            (not (es_ciudad ?localizacion)) ; en la ciudad no se puede cargar ni descargar
            (not (es_puerto ?localizacion)) ; en la ciudad no se puede cargar ni descargar            

            ; capacidad actual del tren                                    
            (siguiente ?ctv1 ?ctv2) 
            (capacidad ?tren ?ctv2)

            ; capacidad actual de la localizacion            
            (siguiente ?ctl1 ?ctl2) 
            (capacidad ?localizacion ?ctl1)             
        )
        :effect (and            
            (cargado ?c ?tren) ; el contenedor esta cargado en el tren
            (not (en ?c ?localizacion)) ; el contenedor no esta ya en la localizacion

            ; se decrementa la capacidad del tren
            (capacidad ?tren ?ctv1)
            (not (capacidad ?tren ?ctv2))

            ; se incrementa la capacidad de la localizacion
            (capacidad ?localizacion ?ctl2)
            (not (capacidad ?localizacion ?ctl1))                                            
        )
    )

    ; se descarga el tren en un localizacion que no sean ni puerto ni ciudad
    ; si la localizacion es un almacen y el contenedor ha sido procesado, este se envia y se saca del sistema
    ; si la localizacion es una fabrica y no ha sido procesado, se procesa; se decrementa la capacidad de la fabrica
    ; se decrementa la capacidad del tren
    (:action descargar
        :parameters (?c - contenedor ?tren - tren ?localizacion - localizacion 
                    ; contador de capacidad del tren
                    ?ctv1 - numero ?ctv2 - numero
                    ; contador de capacidad de la localizacion                     
                    ?ctl1  ?ctl2 - numero)
        :precondition (and       
            ; precondiciones                 
            (en ?tren ?localizacion) ; el tren esta en la localizacion
            (not(enviado ?c)) ; el contenedor no ha sido enviado
            (cargado ?c ?tren) ; el contenedor esta en el tren
            (not (es_ciudad ?localizacion)) ; en la ciudad no se puede cargar ni descargar
            (not (es_puerto ?localizacion)) ; en el puerto no se puede descargar            

            ; capacidad actual del tren
            (siguiente ?ctv1 ?ctv2)
            (capacidad ?tren ?ctv1)

            ; capacidad actual de la localizacion                
            (siguiente ?ctl1 ?ctl2)
            (capacidad ?localizacion ?ctl2)
        )
        :effect (and                        
            (not(cargado ?c ?tren)) ; el contenedor no esta ya en el tren

            ; si la localidad es fabrica: el contenedor es procesado y la capacidad se decrementa
            (when
                ; antecedente
                (and (es_fabrica ?localizacion))

                ; consecuente
                (and (procesado ?c) ; el contenedor es procesado
                    (en ?c ?localizacion) ; el contenedor se mantiene en la fabrica

                    ; se decrementa la capacidad de la fabrica
                    (capacidad ?localizacion ?ctl1)
                    (not (capacidad ?localizacion ?ctl2))
                )
            )

            ; si es fabrica y no esta procesado, se procesa el contenedor
            (when
                ; antecedente
                (and (es_fabrica ?localizacion) (not(procesado ?c))) ; es fabrica y no esta procesado

                ; consecuente
                (and (procesado ?c)) ; se procesa el contenedor
            )

            ; si es un almacen y el contenedor esta procesado, el contenedor se envia
            (when
                ; antecedente
                (and (es_almacen ?localizacion) (procesado ?c)) ; es alamacen y esta procesado

                ; consecuente
                (and (enviado ?c) (not(en ?c ?localizacion))) ; se envia el contenedor y se saca del sistema
            )

            ; se incrementa la capacidad del tren
            (capacidad ?tren ?ctv2)
            (not (capacidad ?tren ?ctv1))            
        )
    )
)