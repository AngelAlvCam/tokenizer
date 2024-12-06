%{
    /*
    Analizador léxico para lenguaje definido en clase
    Compiladores 2023-1
    Autor: Angel Alvarado Campos
    Profesor: M.C. Laura Sandoval Montaño
    Fecha de inicio: 29 de octubre, 2022
    Fecha de entrega: 2 de noviembre

    Objetivo: Elaborar un analizador léxico en Lex/Flex que reconozca a los
    componentes léxicos pertenecientes a las clases descritas para el lenguaje
    definido en clase.

    Descripción: Se trata de un programa que implementa la fase de análisis léxico
    de un compilador para un lenguaje definido en clase. Este analizador léxico
    reconoce las 9 clases definidas por el grupo en el semestre 2023-1, y también
    es capaz de reconocer errores relacionados a las clases descritas.
    */
   
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    //################## ESTRUCTURAS DE DATOS ###########################
    /*
        Definición de las estructuras de datos para las tablas de literales
        Lista ligada para tablas de literales (Clases 3 y 4)
    */
    typedef struct nodo_lit {
        int pos;    // Posicion
        char* dato; // Dato
        struct nodo_lit* next;
    } nodo_lit;

    /*
        Definición de estructura de datos para tabla de símbolos
        Lista ligada para tabla de símbolos (Clase 1)
        No permite duplicados
    */
    typedef struct nodo_tabsim {
        int pos;    // Posición
        char* nombre_id;    // Nombre del identificador
        int tipo;   // Tipo de dato: Inicial es -1 
        struct nodo_tabsim* next;
    } nodo_tabsim;


    //################## PROTOTIPOS DE FUNCIONES ###########################
    int insertar_simbolo(nodo_tabsim**,char*);
    int buscar_simbolo(nodo_tabsim*, char*);
    int print_tabsim(nodo_tabsim*);
    int insertar_literal(nodo_lit**,char*,int);
    int print_tablit(nodo_lit*);
    int valor_palRes(char*);
    int valor_opRela(char*);


    //################## INICIALIZACIONES ###########################
    // Inicialización de tablas de literales
    int num_Reales = -1;
    int num_Constantes = -1;
    nodo_lit* head_Real = NULL; // Tabla de literales de constantes reales (clase 3)
    nodo_lit* head_Cadenas = NULL;  // Tabla de literales de constantes cadenas (clase 4)

    // Inicializacion de tabla de símbolos
    int num_identificadores = -1;
    nodo_tabsim* head_tabsim = NULL;    // Tabla de símbolos (clase 1) 

    // Archivos
    FILE* LiteralesReales;
    FILE* LiteralesCadenas;
    FILE* Simbolos;
    FILE* Tokens;
    FILE* Errores;
    
    //################## DEFINICION DE FUNCIONES ###########################
    /*
        Función que permite realizar la inserción de un identificador en la tabla
        de símbolos. No permite la inserción de valores duplicados.
        Tiene como valor de retorno a un entero que denota la posición en la que
        el identificador fue insertado en la lista, en un rango de posiciones de
        [0, size - 1].
        Si el identificador argumentado ya se encuentra en la lista, entonces se tendrá
        como valor de retorno a la posición del identificador en la tabla de símbolos.
    */
    int insertar_simbolo (nodo_tabsim** head, char* identificador){
        if (buscar_simbolo(*head,identificador) >= 0){
            return buscar_simbolo(*head,identificador);
        } else {
            // Insertar
            num_identificadores++;
            int posicion = num_identificadores;
            nodo_tabsim* nodo_nuevo = (nodo_tabsim*) malloc(sizeof(nodo_tabsim));
            nodo_nuevo -> nombre_id = strdup(identificador);
            nodo_nuevo -> tipo = -1; // Inicial es -1: Se modificará en futuras entregas
            nodo_nuevo -> pos = posicion;
            nodo_nuevo -> next = NULL;
            if (*head == NULL){
                *head = nodo_nuevo;
            } else {
                nodo_tabsim* nodo_aux = *head;
                while (nodo_aux -> next != NULL){
                    nodo_aux = nodo_aux -> next; 
                }
                nodo_aux -> next = nodo_nuevo;
            }
            return nodo_nuevo -> pos;
        }
    }

    /*
        Función auxiliar, permite imprimir el contenidode la tabla de símbolos
    */
    int print_tabsim(nodo_tabsim* head){
        nodo_tabsim* current = head;
        while (current != NULL){
            printf("[%s]", current->nombre_id);
            current = current -> next;
        }
        return 0;
    }

    /*
        Función auxiliar de la función de insertar_simbolo. Se encarga de realizar la búsqueda
        de un identificador argumentado en la tabla de símbolos para identificar si es posible
        realizar la inserción, debido a que no se permiten duplicados en la tabla de símbolos.
        Si el identificador ya se encuentra en la tabla de simbolos, entonces se retorna la
        posición del identificador en la tabla.
        Por otro lado, si el identificador no se encuentra en la tabla se retorna un -1, para
        distinguir que el identificador no se encuentra en una posición de la tabla de simbolos.
    */
    int buscar_simbolo(nodo_tabsim* head, char* identificador){
        nodo_tabsim* current = head;
        while (current != NULL){
            if (strcmp(current -> nombre_id, identificador) == 0){
                // Retorna la posición del identificador en la tab. de simbolos
                return current -> pos;
            }
            current = current -> next;
        }
        // Retorna posición invalida, indicando que no se encuentra en la tabla
        return -1;
    }

    /*
        Permite obtener el valor correspondiente a cada
        palabra reservada (clase 0), según el catalogo
        descrito en los requerimientos del programa.
    */
    int valor_palRes(char* palabra){
        if (strcmp(palabra, "alternative") == 0){
            return 0;
        } else if (strcmp(palabra, "big") == 0) {
            return 1;
        } else if (strcmp(palabra, "evaluate") == 0) {
            return 2;
        } else if (strcmp(palabra, "instead") == 0) {
            return 3;
        } else if (strcmp(palabra, "large") == 0) {
            return 4;
        } else if (strcmp(palabra, "loop") == 0) {
            return 5;
        } else if (strcmp(palabra, "make") == 0) {
            return 6;
        } else if (strcmp(palabra, "number") == 0) {
            return 7;
        } else if (strcmp(palabra, "other") == 0) {
            return 8;
        } else if (strcmp(palabra, "real") == 0) {
            return 9;
        } else if (strcmp(palabra, "repeat") == 0) {
            return 10;
        } else if (strcmp(palabra, "select") == 0) {
            return 11;
        } else if (strcmp(palabra, "small") == 0) {
            return 12;
        } else if (strcmp(palabra, "step") == 0) {
            return 13;
        } else if (strcmp(palabra, "stop") == 0) {
            return 14;
        } else if (strcmp(palabra, "symbol") == 0) {
            return 15;
        } else {   
            // if palabra es "throw"
            return 16;
        }
    }

    /*
        Función que permite obtener el valor entero del
        operador relacional (clase 7), según lo descrito en el
        catalogo de operadores relacionales descrito
        en los requerimientos del programa.
    */
    int valor_opRela(char* operador){
        if (strcmp(operador, "<") == 0){
            return 0;
        } else if (strcmp(operador, ">") == 0){
            return 1;
        } else if (strcmp(operador, "<=") == 0){
            return 2;
        } else if (strcmp(operador, ">=") == 0){
            return 3;
        } else if (strcmp(operador, "==") == 0){
            return 4;
        } else {
            // if operador es "!="
            return 5;
        }
    }

    /*
        Permite insertar nuevos valores en las tablas de literales
        No verifica si hay duplicados para realizar la inserción, por lo cual se aceptan duplicados.
        Tiene como valor de retorno a la posición del nuevo valor en la tabla.
        Es usada para la tabla de literales de enteros (clase 1), reales (clase 2) y cadenas (clase 3)
    */
    int insertar_literal (nodo_lit** head, char* valor, int clase){
        int posicion = -1;
        if (clase == 3){ // Clase 3: Reales
            num_Reales++;
            posicion = num_Reales;
        } else if (clase == 4){ // Clase 4: Cadenas
            num_Constantes++;
            posicion = num_Constantes;
        }

        if (posicion != -1){    // Si es clase 3 o 4
            nodo_lit* nuevoNodo = (nodo_lit*) malloc(sizeof(nodo_lit));
            nuevoNodo -> dato = strdup(valor);
            nuevoNodo -> next = NULL;
            nuevoNodo -> pos = posicion;
            if (*head == NULL){
                *head = nuevoNodo;
            } else {
                nodo_lit* nodoAux = *head;
                while (nodoAux -> next != NULL){
                    nodoAux = nodoAux -> next;
                }
                nodoAux -> next = nuevoNodo;
            }
            return nuevoNodo -> pos;    // Retorna posición de la inserción actual
        }
        return -1;
    }

    /*
        Función auxiliar, permite imprimir el contenido de las tablas de literales
    */
    int print_tablit(nodo_lit* head){
        nodo_lit* current = head;
        while (current != NULL){
            printf("[%s]", current->dato);
            current = current -> next;
        }
        return 0;
    }

    /*
        Función que permite escribir el contenido de una tabla de literales 
        (de constantes numéricas reales o constantes cadenas) descrita por un nodo
        de tipo nodo_lit en un archivo argumentado de tipo FILE*.
    */
    int write_tablit(FILE* archivo, nodo_lit* head){
        nodo_lit* current = head;
        int posicion = 0;
        while (current != NULL){  
            fprintf(archivo, "%d\t%s\n", posicion, current->dato);
            current = current -> next;
            posicion++;
        }
        return 0;
    }

    /*
        Función que permite escribir el contenido de una tabla de simbolos
        descrita por un nodo de tipo nodo_tabsim en un archivo argumentado de tipo FILE*.
    */
    int write_tabsim(FILE* archivo, nodo_tabsim* head){
        nodo_tabsim* current = head;
        int posicion = 0;
        while (current != NULL){
            fprintf(archivo, "%d\t%s\t%d\n", posicion, current->nombre_id, -1);
            current = current -> next;
            posicion++;
        }
        return 0;
    }

    /*
        Función que permite leer el contenido de un archivo argumentado de tipo FILE*
        desde la terminal.
    */
    int read_file(FILE* archivo){
        char c_aux;
        fread(&c_aux,sizeof(char),1,archivo);
        while(feof(archivo) == 0){
            printf("%c",c_aux);
            fread(&c_aux,sizeof(char),1,archivo);
        }
        printf("\n\n");
        return 0;
    }
%}

palRes alternative|big|evaluate|instead|large|loop|make|number|other|real|repeat|select|small|step|stop|symbol|throw
ERRpalRes [A-Za-z]+

identificador \$([A-Za-z]+)
ERR1 \$
ERR2 (\$[^A-Za-z\n](([A-Za-z]|[^A-Za-z\n])*))
ERR3 (\$([A-Za-z]+)[^A-Za-z\n](([A-Za-z]|[^A-Za-z\n])*))
ERRcadenas {ERR1}|{ERR2}|{ERR3}

ctsNumReal ([1-9]([0-9]*))?\.([0-9]+)
ERRctsNumReal (\.)|([1-9]([0-9]*)(\.+))|(0([0-9]*)(\.+)(([0-9]|\.)*))

ctsNumEnt ([1-9][0-9]*)|(0)|([oO][0-7]+)
ERRctsNumEnt (0[0-9]+)|([oO][89](0-9)*)|([oO][0-7]+[89][0-9]*)

simEsp \[|\]|\(|\)|\{|\}|,|;|:
opArit (\+)|(\-)|(\*)|(\/)|(\%)|(\\)|(\^)
opRela (<)|(>)|(<=)|(>=)|(==)|(!=)
opAsig (=)

chars [^\'\"]
ctsCadenas (\"\'\")|(\'\"\')|(\'{chars}\')|(\"{chars}({chars}+)\")
chars2 [^\'\"\n]
ERRctsCadenas1 (\'\'|\'({chars2}|\")({chars2}|\")|\'(\"|{chars2})\'({chars2}|\'|\"))(\'|{chars2}|\")*
ERRctsCadenas2 (\"\"|\"{chars2}(\'|\")|\"{chars2}({chars2}+)(\'|\"({chars2}|\'|\"))|\"\'(\'|{chars2}))(\'|{chars2}|\")*
ERRctsCadenas {ERRctsCadenas1}|{ERRctsCadenas2}

%%
{palRes} {
    // CLASE 0
    fprintf(Tokens, "(0\t%d)\n", valor_palRes(yytext)); // Token clase 0
}
{ERRpalRes} {
    fprintf(Errores, "ERROR LÉXICO, PALABRAS RESERVADAS: %s\n", yytext);
}
{ERRcadenas} {
    fprintf(Errores, "ERROR LÉXICO, IDENTIFICADORES: %s\n", yytext);
}
{identificador} {
    // CLASE 1
    fprintf(Tokens, "(1\t%d)\n", insertar_simbolo(&head_tabsim, yytext)); // Token clase 1
}
{ctsCadenas} {
    // CLASE 4
    fprintf(Tokens, "(4\t%d)\n", insertar_literal(&head_Cadenas, yytext, 4)); // Token clase 4
}
{ERRctsCadenas} {
    fprintf(Errores, "ERROR LÉXICO, CADENAS: %s\n", yytext);
}
{ctsNumReal} {
    // CLASE 3
    // Prioridad sobre las enteras
    fprintf(Tokens, "(3\t%d)\n", insertar_literal(&head_Real, yytext, 3)); // Token clase 3
}
{ERRctsNumReal} {
    fprintf(Errores, "ERROR LÉXICO, NUMEROS REALES: %s\n", yytext);
}
{ERRctsNumEnt} {
    fprintf(Errores, "ERROR LÉXICO, NUMEROS ENTEROS: %s\n", yytext);
}
{ctsNumEnt} {
    // CLASE 2
    fprintf(Tokens, "(2\t%s)\n", yytext); // Token clase 2
}
{opAsig} {
    // CLASE 8
    // Prioridad sobre las relacionales
    fprintf(Tokens, "(8\t=)\n");    // Token clase 8
}
{opRela} {
    // CLASE 7
    fprintf(Tokens,"(7\t%d)\n", valor_opRela(yytext));  // Token clase 7
}
{opArit} {
    // CLASE 6
    fprintf(Tokens, "(6\t%s)\n", yytext);   // Token clase 6
}
{simEsp} {
    // CLASE 5
    fprintf(Tokens, "(5\t%s)\n", yytext); // Token clase 5
}
%%

int main(int argc, char* argv[]){
    yyin = fopen(argv[1], "r"); // Se recibe al archivo de interés con componentes léxicos

    // Se crean los archivos y se realizan escrituras utiles
    Tokens = fopen("Tokens.txt", "w");  // Archivo para TOKENS
    fprintf(Tokens, "TOKENS\nCLASE\tVALOR\n");
    LiteralesReales = fopen("TablaLiteralesReales.txt", "w");  // Archivo para tabla de literales reales
    fprintf(LiteralesReales, "TABLA DE LITERALES REALES (CLASE 3)\nPOSICION\tDATO\n");
    LiteralesCadenas = fopen("TablaLiteralesCadenas.txt", "w");    // Archivo para tabla de literales cadenas
    fprintf(LiteralesCadenas, "TABLA DE LITERALES CADENAS (CLASE 4)\nPOSICION\tDATO\n");
    Simbolos = fopen("TablaSimbolos.txt", "w");    // Archivo para tabla de simbolos
    fprintf(Simbolos, "TABLAS DE SIMBOLOS (CLASE 1)\nPOSICION\tNOMBRE DEL IDENTIFICADOR\tTIPO\n");
    Errores = fopen("Errores.txt", "w");
    fprintf(Errores, "ERRORES LÉXICOS\n");

    yylex();

    // Una vez que concluye la lectura del archivo y se llenan las tablas, se añade la info. en los archivos
    write_tablit(LiteralesReales,head_Real);
    write_tablit(LiteralesCadenas,head_Cadenas);
    write_tabsim(Simbolos,head_tabsim);

    // Cierra escritura de archivos
    fclose(Tokens);
    fclose(LiteralesReales);
    fclose(LiteralesCadenas);
    fclose(Simbolos);
    fclose(Errores);

    // Lectura de archivos
    Tokens = fopen("Tokens.txt", "r");  // Archivo para TOKENS
    LiteralesReales = fopen("TablaLiteralesReales.txt", "r");  // Archivo para tabla de literales reales
    LiteralesCadenas = fopen("TablaLiteralesCadenas.txt", "r");    // Archivo para tabla de literales cadenas
    Simbolos = fopen("TablaSimbolos.txt", "r");    // Archivo para tabla de simbolos
    Errores = fopen("Errores.txt", "r");
    read_file(Simbolos);
    read_file(LiteralesReales);
    read_file(LiteralesCadenas);
    read_file(Tokens);
    read_file(Errores);

    // Se cierra la lectura de archivos 
    fclose(Tokens);
    fclose(LiteralesReales);
    fclose(LiteralesCadenas);
    fclose(Simbolos);
    fclose(Errores);
    printf("\n");
    return 0;
}