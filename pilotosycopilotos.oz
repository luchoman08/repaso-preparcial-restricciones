declare DictPilotos DictCopilotos DictAux
%entrada de datos
Pilotos = [duque petro fajardo]
Copilotos = [uribe clara claudia]
PreferenciasPilotos = preferenciasPilotos(petro: [clara] duque: [uribe] fajardo: [claudia])
PreferenciasCopilotos = preferenciasCopilotos(uribe:[duque] clara:[petro] claudia: [fajardo])
%{Browse Copilotos}

proc {Echo X Y?}
   Y = X
end

   

%Crea un diccionario con objectos de una lista como llaves, y los valores son ids numericos creados
proc { InitKeys List DictAux FirstValue DictResult?}
   %{Browse DictPilotos}
   case List
   of nil then DictResult = DictAux
   [] X | Xr then
      {Dictionary.put DictAux X FirstValue}
      {InitKeys Xr DictAux FirstValue + 1 DictResult}
   end
end

fun {InitKeysF List}
   local DictAux DictResult in
      DictAux = {Dictionary.new}
      DictResult = {InitKeys List DictAux 1}
      DictResult
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
      {InitKeys List DictAux 0 Dict}
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
%{Browse PreferenciasCopilotos}
%{Browse {Dictionary.condGet DictPilotos carlos ~1 }}

%fun {FDParejasPilotoCop Pilotos Copilotos}

% Preferencias: registro donde cada atributo del registro es el individuo preferente y el valor de dicho atributo
% es una lista de preferencias
fun {GetRecordFeatures Rec}
   local Keys in
      Keys = {Dictionary.keys {Record.toDictionary Rec}}
      Keys
   end
end

proc {DuplasPreferencias Preferente Preferencias ListAux  DuplasResultado?}
   case Preferencias of nil then DuplasResultado = ListAux.2
   [] X | Xr then
      {DuplasPreferencias Preferente Xr {List.append ListAux [Preferente#X]} DuplasResultado}
   end
end
%Dr = {DuplasPreferencias carlos PreferenciasPilotos.carlos [nil] }
%{Browse Dr}

fun {DuplasPreferenciasF Preferente Preferencias}
   local Resultado in
      {DuplasPreferencias Preferente Preferencias [nil] Resultado}
      Resultado
   end
end
%{Browse {DuplasPreferenciasF carlos PreferenciasPilotos.carlos}}

%preferents: lista de preferentes en atomos
%preferencias: record donde las llaves son los preferentes, los valores son las preferencias
proc {DuplasPreferenciasFromRecord RecordPreferencias  Resultado?}
   local ListAux in
      ListAux = {NewCell [nil]}
      {ForAll {GetRecordFeatures RecordPreferencias}
       proc {$ Preferente}
	 ListAux := {List.append @ListAux {DuplasPreferenciasF Preferente RecordPreferencias.Preferente}}
       end
      }
      Resultado = @ListAux.2
   end
end

% {Browse {DuplasPreferenciasFromRecord PreferenciasPilotos}}
% @arg DuplaPreferencia:atom#atom prefererente#preferido
% @arg DictFDPreferencias: atom:FD.int indica la variable que determinara el asignado al elemento atom
% @arg DictPreferidosKeys: atom:id  indica que id tiene un preferido
% @arg VoltearTupla: boolean en caso de que se desee ingresar una dupla de preferencia en orden inverso, los preferidos tambien prefieren
% a los preferentes
proc {ReificarPreferencia DictFDPreferencias DuplaPreferencia DictPreferidosKeys VoltearTupla S?}
   %{Browse DuplaPreferencia}
   local
      IdPreferido % id de el preferido 
      FDPreferencia % Variable de dominio finito que representa el dominio de preferencias de el preferente
      FirstIndex
      SecondIndex
   in
      if VoltearTupla then
	 FirstIndex = 2
	 SecondIndex = 1
      else
	 FirstIndex = 1
	 SecondIndex = 2
      end
      IdPreferido =  {Dictionary.condGet DictPreferidosKeys DuplaPreferencia.SecondIndex ~1}
      FDPreferencia =  {Dictionary.get DictFDPreferencias DuplaPreferencia.FirstIndex} 
       {FD.reified.sum [FDPreferencia] '=:' IdPreferido  S }
   end
  
end


proc {AsignarCopilotos Root?}
   local
      Pilotos
      Copilotos
      NumPilotos
      NumCopilotos
      DictPilotosID % diccionario donde la llave son los pilotos y los valores ids creados de 1 hasta num pilotos
      DictCopilotosID % igual que arriba para copilotos
      VarsReificarPreferenciasPilotos % igual que el siguiente pero para pilotos
      VarsReificarPreferenciasCopilotos % Lista de variables objetivo de reificacion de preferencias
      DictFDPreferenciasPilotos
      DuplasPreferenciasPilotos % lista de duplas de preferneicas de pilotos de la forma piloto#copiloto donde piloto prefiere a copiloto
      DuplasPreferenciasCopilotos
      Satisfaction % numero de restricciones satisfechas posibles
      PreferenciasSatisfechasPilotos
      PreferenciasSatisfechasCopilotos
   in
      Pilotos = {GetRecordFeatures PreferenciasPilotos}
      NumPilotos = {List.length Pilotos}
      Copilotos = {GetRecordFeatures PreferenciasCopilotos}
      NumCopilotos = {List.length Copilotos}
      DictPilotosID = {InitKeysF Pilotos}
      DictCopilotosID = {InitKeysF Copilotos}
      DictFDPreferenciasPilotos = {GetFDDictFromList Pilotos 1 {List.length Copilotos}}
      DuplasPreferenciasPilotos = {DuplasPreferenciasFromRecord PreferenciasPilotos}
      DuplasPreferenciasCopilotos = {DuplasPreferenciasFromRecord PreferenciasCopilotos}
      Satisfaction  = {FD.decl}
      {Browse {Dictionary.entries DictCopilotosID}}
      proc {PreferenciasSatisfechasPilotos DuplaPreferencia S?}
	 {ReificarPreferencia  DictFDPreferenciasPilotos DuplaPreferencia DictCopilotosID false S}
      end
      proc {PreferenciasSatisfechasCopilotos DuplaPreferencia S?}
	 {ReificarPreferencia  DictFDPreferenciasPilotos DuplaPreferencia DictCopilotosID true S}
      end
      %{Browse hola#{Map DuplasPreferenciasPilotos PreferenciasSatisfechasPilotos}}
      Root = resultado(dictPreferencias: DictFDPreferenciasPilotos satisfaction: Satisfaction)
      {Browse {Dictionary.items DictFDPreferenciasPilotos}}
      {FD.sum
       {List.append
	{Map DuplasPreferenciasCopilotos PreferenciasSatisfechasCopilotos }
	{Map DuplasPreferenciasPilotos PreferenciasSatisfechasPilotos}
       }
       '=:' Satisfaction}
     
      {FD.distinct {Dictionary.items DictFDPreferenciasPilotos}}
      {FD.distribute generic(order:naive value:max) [Satisfaction]}
      {FD.distribute ff {Dictionary.items DictFDPreferenciasPilotos}}
      
%      {Dictionary.get DictFDPreferenciasPilotos petro}
   end
end

proc {MejorAsignacionCopilotos Old New}
   Old.satisfaction <: New.satisfaction
end   


{ExploreBest AsignarCopilotos  MejorAsignacionCopilotos}
%{Browse 5}
%{Browse {GetRecordFeatures PreferenciasPilotos}}
%DictFDPilotos = {GetFDDictFromList Pilotos 1 {List.length Copilotos}}
%{Browse {Dictionary.condGet DictFDPilotos carlos ~1}}
%{Dictionary.condGet DictFDPilotos carlos ~1} =: 1
%{Browse hola}

  