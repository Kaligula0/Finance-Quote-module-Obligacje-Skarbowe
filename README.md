# Finance-Quote-module-Obligacje-Skarbowe

Moduł do [Finance::Quote](https://github.com/finance-quote/finance-quote) (i [GnuCash](https://www.gnucash.org)) obliczający wartość posiadanych przez użytkownika [polskich obligacji skarbowych](https://www.obligacjeskarbowe.pl). Napisany w Perlu, oczywiście, bo Finance::Quote.

# Stan rozwoju

Wersja BETA, która sama pobiera dane o inflacji (ze Stooq.pl) i w ogóle w końcu poprawnie oblicza wartość obligacji. Kod zawiera jeszcze zmienne służące do debugowania i jest nieposprzątany. 

Na razie obsługuje obligacje indeksowane inflacją (COI, EDO, ROS i ROD) mimo że symbole innych obligacji pojawiają się też w kodzie (być może da się ten moduł do nich też zastosować, ale nie sprawdzałem).

# Instalacja

Pobierz plik `ObligacjeSP.pm` i wklej go do folderu Finance::Quote (prawdopodobnie `<perl_dir>\site\lib\Finance\Quote`). Potem dopisz `ObligacjeSP` (najlepiej w kolejności alfabetycznej) do zmiennej `@MODULES` w pliku `Quote.pm` (`<perl_dir>\site\lib\Finance`).

# Użycie

Na tym etapie rozwoju modułu użytkownik musi podać (razem z symbolem obligacji) jej datę (dzień) zakupu i oprocentowanie (w pierwszym roku i oprocentowanie ponad inflację w kolejnych). Nie znalazłem żadnego API ani tabeli/spisu w internecie, skąd moduł mógłby to pobierać. Nie mam na razie lepszego pomysłu, proszę Was o podsunięcie jakiegoś rozwiązania.

W GnuCashu trzeba obligacjom nadać odpowiednie symbole (którymi GnuCash odpytuje moduły F::Q). Symbole powinny mieć formę
```[SymbolOryginalny]-dXX-pY.YY-iZ.ZZ```
gdzie:
* `SymbolOryginalny` to np. `COI0127` (jak na stronie internetowej [obligacjeskarbowe.pl](https://www.obligacjeskarbowe.pl/))
* `dXX` to dzień zakupu, dwucyfrowo (odsetki są naliczane codziennie, więc dokładna data zakupu jest ważna), np. `d29`
* `pY.YY` to oprocentowanie w pierwszym roku, np. `p7.00`
* `iY.YY` to oprocentowanie ponad inflację w kolejnych latach, np. `i0.50`
Użycie w GnuCashu nie wymaga więcej czynności, GnuCash sam skonstruuje poprawne zapytanie.

Użycie ręczne:

```
use Finance::Quote;
$q = Finance::Quote->new;
$symbol = "COI0127-d29-p7.00-i0.50";
%info  = $q->fetch("obligacje_sp", $symbol);
print "success= ".$info{$smbl, "success"}."\n";
print "symbol= ".$info{$smbl, "symbol"}."\n";
print "date= ".$info{$smbl, "isodate"}."\n";
print "name= ".$info{$smbl, "name"}."\n";
print "price= ".$info{$smbl, "price"}."\n";
```

# Błędy, uwagi, sugestie, pomoc, współpraca

Zgłaszajcie w Issues. Zachęcam do współpracy, bo nie jestem informatykiem i pierwszy raz mam do czynienia z Perlem ;P Pozdro

# License
GPL 2.0
