# Finance-Quote-module-Obligacje-Skarbowe

Moduł do [Finance::Quote](https://github.com/finance-quote/finance-quote) (i [GnuCash](https://www.gnucash.org)) obliczający wartość posiadanych przez użytkownika [polskich obligacji skarbowych](https://www.obligacjeskarbowe.pl). Napisany w Perlu, oczywiście, bo Finance::Quote.

# Stan rozwoju

Wersja ALPHA - pierwsza, która sama pobiera dane o inflacji (ze Stooq.pl) i w ogóle w końcu poprawnie oblicza wartość obligacji. Kod zawiera jeszcze zmienne służące do debugowania i jest nieposprzątany. 

Na razie obsługuje obligacje indeksowane inflacją: EDO i COI, mimo że symbole innych obligacji pojawiają się też w kodzie (być może da się ten moduł też zastosować już do ROD i ROS, nie sprawdzałem). Pozostałe może w przyszłości.

# Instalacja

Pobierz plik `ObligacjeSP.pm` i wklej go do folderu Finance::Quote (prawdopodobnie `<perl_dir>\site\lib\Finance\Quote`). Potem dopisz `ObligacjeSP` (najlepiej w kolejności alfabetycznej) do zmiennej `@MODULES` w pliku `Quote.pm` (`<perl_dir>\site\lib\Finance`).

# Użycie

Na tym etapie rozwoju modułu użytkownik musi swoje obligacje wpisać w zmienną `my %rates` (oprocentowanie w pierwszym roku i oprocentowanie ponad inflację w kolejnych). Nie wiem jak będzie kiedyś i co można tu poprawić.

W GnuCashu trzeba obligacjom nadać odpowiednie symbole (którymi GnuCash odpytuje moduły F::Q). Symbole powinny mieć formę `[SymbolOryginalny]-DD`, gdzie `SymbolOryginalny` to np. `EDO0831` (jak na stronie internetowej [obligacjeskarbowe.pl](https://www.obligacjeskarbowe.pl/)), a `DD` to dzień zakupu dwucyfrowo (odsetki są naliczane codziennie, więc dokładna data zakupu jest ważna dla modułu). Użycie w GnuCashu nie wymaga więcej czynności, GnuCash sam skonstruuje poprawne zapytanie.

Użycie ręczne:

```
use Finance::Quote;
$q = Finance::Quote->new;
$symbol = "EDO0831-04";
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
