declare DictPilotos DictCopilotos DictAux
%entrada de datos
Pilotos = [juan carlos]
Copilotos = [duque santos]
PreferenciasPilotos = preferenciasPilotos(juan: [duque] carlos: [santos])
PreferenciasCopilotos = preferenciasCopilotos(duque:[juan] santos:[carlos])
{Browse Copilotos}

proc {Echo X Y?}
   Y = X
end

%local Y = {Echo 5} in {Browse Y } end
   
fun {Map Xs F}
   case Xs
   of nil then nil
   [] X|Xr then {F X}|{Map Xr F}
   end 
end 
%Crea un diccionario con objectos de una lista como llaves, y los valores son ids numericos creados
proc { InitKeys List DictAux FirstValue DictResult?}
   %{Browse DictPilotos}
   case List
   of nil then DictResult = DictAux
   [] X | Xr then
      {Dictionary.put DictAux X Value}
      {InitPilotos Xr DictAux FirstValue + 1 DictResult}
   end
end

% genera un diccionario con objetos de una lista como llaves, y los valores son FD vars desde min hasta max
proc { InitFD List DictAux Min Max DictResult?}
   %{Browse DictPilotos}
   case List
   of nil then DictResult = DictAux
   [] X | Xr then
      local FDVar in
	 FDVar::Min#Max
	 {Dictionary.put DictAux X FDVar}
	 {InitFD Xr DictAux Min Max DictResult}
      end
      
   end
end


fun {GetDictFromList List}
   local DictAux Dict in
      DictAux = {Dictionary.new}
      {InitPilotos List DictAux 0 Dict}
      Dict
   end
end
fun {GetFDDictFromList List Min Max}
   local DictAux Dict in
      DictAux = {Dictionary.new}
      {InitFD List DictAux Min Max Dict}
      Dict
   end
end

DictCopilotos = {GetDictFromList Copilotos}
DictPilotos = {GetDictFromList Pilotos}
{Browse PreferenciasCopilotos}
{Browse {Dictionary.condGet DictPilotos carlos ~1 }}

%fun {FDParejasPilotoCop Pilotos Copilotos}
DictFDPilotos = {GetFDDictFromList Pilotos 1 {List.length Copilotos}}
{Browse {List.nth PreferenciasPilotos.carlos 1}}
local C in
   C::4#6
   C=:5
   {Browse C}
end

{Browse {Dictionary.condGet DictFDPilotos carlos ~1}}
{Dictionary.condGet DictFDPilotos carlos ~1} =: 1


  