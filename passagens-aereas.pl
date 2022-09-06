%voo(origem,destino,codigo,partida,(dia_chegada,horario_chegada),escalas,companhia,[dias]).
voo(sao_paulo,mexico,g01,1:30,(mesmo,13:30),0,tam,[segunda,quarta,sexta]).
voo(sao_paulo,nova_york,g02,1:00,(mesmo,16:00),1,gol,[segunda,sexta]).
voo(sao_paulo,lisboa,g03,10:00,(seguinte,5:00),1,gol,[terca,quinta,sexta]).
voo(sao_paulo,madrid,g04,23:00,(seguinte,11:00),0,azul,[quinta,sabado]).
voo(sao_paulo,londres,g05,8:30,(mesmo,15:30),1,azul,[segunda,terca,quinta]).
voo(sao_paulo,paris,g06,15:00,(seguinte,7:00),1,tam,[terca,sexta]).

voo(mexico,nova_york,g07,9:00,(mesmo,15:00),0,gol,[terca,quarta,sexta]).
voo(mexico,madrid,g08,18:30,(seguinte,12:30),0,tam,[segunda,quinta,sabado]).

voo(nova_york,londres,g09,23:00,(seguinte,11:00),0,azul,[domingo,sexta]).

voo(londres,lisboa,g10,17:30,(mesmo,20:30),0,azul,[segunda,terca,sexta]).
voo(londres,paris,g11,14:00,(mesmo,16:00),0,gol,[segunda,quinta,sexta]).
voo(londres,estocolmo,g12,8:30,(mesmo,11:30),0,tam,[domingo,terca,quinta]).

voo(madrid,paris,g13,7:00,(mesmo,9:00),0,tam,[domingo,segunda,sexta]).
voo(madrid,roma,g14,18:30,(mesmo,21:00),0,tam,[domingo,quinta]).
voo(madrid,frankfurt,g15,16:00,(mesmo,18:30),0,gol,[segunda]).

voo(frankfurt,estocolmo,g16,7:00,(mesmo,9:00),0,azul,[domingo,terca]).
voo(frankfurt,roma,g17,18:30,(mesmo,20:30),0,azul,[quarta,quinta,sabado]).

% Funcao 1
voo_direto(Origem,Destino,Companhia,Dia,Horario):-
	voo(Origem,Destino,_,Horario,_,0,Companhia,L),
	pertence(Dia,L).

pertence(X,[X|_]).
pertence(X,[_|L]):-
	pertence(X,L).

% Funcao 2
roteiro(Origem,Destino,Codigo):-
	voo(Origem,Destino,Codigo,_,_,_,_,_).
roteiro(Origem,Destino,[Lista|Codigo]):-
	voo(Origem,Destinoaux,Lista,_,_,_,_,_),
	roteiro(Destinoaux,Destino,Codigo).

% Funcao 3
filtra_voo_dia_semana(Origem,Destino,DiaSemana,HorarioSaida,HorarioChegada,Companhia) :-
	voo(Origem,Destino,_,HorarioSaida,(_,HorarioChegada),0,Companhia,Dia),
	pertence(DiaSemana,Dia).

% Funcao 4
%(passar para um lista as duracoes e pegar a menor busca dados)
%Menor elemento da lista de duracoes de viajem
menorDuracao(Origem,Destino,DiaSaida2,HorarioSaida,HorarioChegada,Companhia):-
	findall(Duracao,roteiroMinutos(Origem,Destino,DiaSaida,HorarioSaida,Duracao),Lista),
	menorElemento(Lista,Min),
	roteiroMinutos(Origem,Destino,DiaSaida,HorarioSaida,Min),
	voo(Origem,Destino,_,HorarioSaida,(_,HorarioChegada),0,Companhia,_),
	pertence(DiaSaida2,DiaSaida).

menorElemento([X],X).
menorElemento([X|Y],M):-
	menorElemento(Y,N),%"if then else"
	(X<N -> M=X; M=N). %if()->(acao);else(acao)

%Funcao 4
%tempo de UMA viajem em MINUTOS
roteiroMinutos(Origem,Destino,Diasaida,Horariosaida,Duracao):-
	voo(Origem,Destino,_,Horariosaida,(Dia_chegada,Horario_chegada),_,_,Diasaida),
	soma24(Dia_chegada,Horario_chegada,Horario_chegadaF),
	tempoMinutos(Duracao,Horariosaida,Horario_chegadaF,_,_).

%Funcao 4
%converte tudo em minutos, faz a soma e retorna em minutos
tempoMinutos(Minuto,HoraPartida:MinutoPartida,HoraChegada:MinutoChegada,DuracaoPartida,DuracaoChegada):-
	DuracaoPartida is HoraPartida * 60 + MinutoPartida,
	DuracaoChegada is  HoraChegada * 60 + MinutoChegada,
	DuracaoTotal is DuracaoChegada - DuracaoPartida,
	verificaMinutos(DuracaoTotal,Minuto).

%Corrige caso chegue no dia seguinte
soma24(DiaChegada,HorarioChegada:MinutoChegada,HorarioChegadaFinal:MinutoChegadaFinal):-
	HorarioChegadaFinal is HorarioChegada,
	MinutoChegadaFinal is  MinutoChegada,
	DiaChegada = mesmo,
	!.

soma24(_,HorarioChegada:MinutoChegada,HorarioChegadaFinal:MinutoChegadaFinal):-
	HorarioChegadaFinal is HorarioChegada + 24,
	MinutoChegadaFinal is MinutoChegada.

%tratamento em caso negativo
verificaMinutos(D_minuto,D_saidaM):-
	D_minuto < 0,
	D_saidaM is D_minuto + 1440,
	!.

verificaMinutos(D_minuto,D_saidaM):-
	D_saidaM is D_minuto.

%Funcao 5 (Tempo AR)
roteiroAr(Origem,Destino,Dia,Sai,TempoAr):-
	tempoAr(Origem,Destino,Dia,Sai,TempoAr),
	TempoAr is TempoAr.

%Funcao 5 (Tempo no AR)
tempoAr(Origem,Destino,Dia,Sai,Duracao):-
	voo(Origem,Destino,_,Sai,(DiaChegada,Chega),_,_,Dia),
	soma24(DiaChegada,Chega,ChegaDiaSeguinte),
	tempoMinutos(Duracao,Sai,ChegaDiaSeguinte,_,_).

tempoAr(Origem,Destino,DiaSaida,Saida,Duracao):-
	voo(Origem,DestinoAux,_,Saida,(DiaChegada,Chegada),_,_,DiaSaida),
        tempoAr(DestinoAux,Destino,_,_,L),
	soma24(DiaChegada,Chegada,ChegaDiaSeguinte),
	tempoMinutos(DuracaoAux,Saida,ChegaDiaSeguinte,_,_),
	Duracao is DuracaoAux + L.

%Funcao 5 (Tempo AR + TEMPO TERRA)
roteiroArTerra(Origem,Destino,Dia,Sai,TempoArTerra):-
	tempoAr(Origem,Destino,Dia,Sai,TempoAr),
	tempoTerra(Origem,Destino,Dia,Sai,TempoTerra),
	TempoArTerra is TempoAr + TempoTerra.

%Funcao 5 (TEMPO TERRA)
tempoTerra(Origem,Destino,Dias,Sai,Duracao):-
       voo(Origem,Destino,_,Sai,(_,_),_,_,Dias),
       Duracao = 0,
       !.

tempoTerra(Origem,Destino,_,Saida,Duracao):-
	%voo(origem,destino,c�digo,partida,(dia_chegada,horario_chegada),escalas,companhia,[dias]).
	voo(Origem,DestinoAux,_,Saida,(DiaChegada,Chegada1),_,_,Dia1),
	tempoTerra(DestinoAux,Destino,Dia2,Sai2,L),
	soma24T(DiaChegada,Mais24h),
	tempoMinutos(D1,Chegada1,Sai2,_,_),
	soma(Dia1,Dia2,DiaChegada,DiferencaDia),
	Duracao is D1 + Mais24h + DiferencaDia + L,
	!.

%Corrige caso chegue no dia seguinte
soma24T(DiaChegada,MinutoChegadaFinal):-
	MinutoChegadaFinal is 0,
	DiaChegada = mesmo,
	!.

soma24T(_,MinutoChegadaFinal):-
	MinutoChegadaFinal is 1440.

soma([Dia1|_],[Dia2|_],DiaChegada,Diferenca):-
	Dia1 = Dia2,
	Diferenca is 0;
	dianum(Dia1,Dia1num),
	dianum(Dia2,Dia2num),
	%se for negativo, passou uma semana at� o proximo voo disponivel
	Sub is Dia2num - Dia1num,
	(Sub < 0 -> Sub2 = 6;
	Sub2 = Sub),
	DiferencaAux is 1440 * Sub2,
	%retira tempo contado duas vezes de soma24 quando OUTRODIA
	(DiaChegada = seguinte -> Diferenca = DiferencaAux - 1440;
	Diferenca = DiferencaAux).

dianum(domingo,0).
dianum(segunda,1).
dianum(terca,2).
dianum(quarta,3).
dianum(quinta,4).
dianum(sexta,5).
dianum(sabado,6).

