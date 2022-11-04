# Finance-Quote-module-Obligacje-Skarbowe

Moduł do [Finance::Quote](https://github.com/finance-quote/finance-quote) (i [GnuCash](https://www.gnucash.org/)) obliczający wartość posiadanych przez użytkownika [polskich obligacji skarbowych](https://www.obligacjeskarbowe.pl/). Napisany w Perlu, oczywiście, bo Finance::Quote.

# Stan rozwoju

Obecnie jest to pierwsza wersja, która sama pobiera dane o inflacji (ze Stooq.pl) i w ogóle poprawnie oblicza wartość obligacji.

Na razie obsługuje obligacje indeksowane inflacją: EDO i COI, mimo że symbole innych obligacji pojawiają się też w kodzie (być może da się też zastosować go do ROD i ROS). Pozostałe może w przyszłości.

# Użycie

Na tym etapie rozwoju użytkownik musi swoje obligacje wpisać w zmienną `my %rates` (oprocentowanie w pierwszym roku i w kolejnych).

Zapytanie o wartość powinno mieć formę `[symbol]-DD`, gdzie `symbol` to np. `EDO0831` a `DD` to dzień zakupu (odsetki są naliczane codziennie, więc dokładna data zakupu jest ważna dla modułu).

```
use Finance::Quote;
$q = Finance::Quote->new;
$symbol = "EDO1131-04";
%info  = $q->fetch("obligacje_sp", $symbol);
```

# Błędy, uwagi, sugestie, pomoc, współpraca

Zgłaszajcie w Issues. Pozdro
