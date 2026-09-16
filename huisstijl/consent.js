/* consent.js: cookie banner + Google Consent Mode v2 (analytics_storage only). Same logic as clustertriage.com; the choice is stored in localStorage under cl_consent. */
/* ---- de cookiebanner -------------------------------------------------------
   Google Analytics staat in de <head> van elke pagina, maar met Consent Mode
   en met alles op denied. Dat betekent dat de tag wel draait en niets opslaat:
   er wordt geen cookie geplaatst en er gaat niets naar Google totdat hieronder
   een update volgt. Weigert de bezoeker, dan blijft het bij die beginstand en
   hoeft er dus niets ongedaan gemaakt te worden.

   De keuze staat in localStorage onder cl_consent, dezelfde sleutel en
   dezelfde twee waarden als de oude site gebruikte. Dat is met opzet: wie daar
   al ja of nee heeft gezegd krijgt de vraag niet opnieuw.

   Vier dingen kunnen ontbreken en geen ervan mag iets breken. Er is geen balk
   op pagina's waar hij niet is uitgerold; localStorage kan geweigerd worden in
   een afgeschermd venster; gtag kan er niet zijn als een blokkeerder het
   script tegenhoudt; en de knop in de voettekst staat er alleen op pagina's
   met een voettekst. Vandaar overal een controle en overal een try. */
(function(){
  var SLEUTEL = 'cl_consent';
  var balk    = document.getElementById('cookiebalk');
  if(!balk) return;

  var ja  = document.getElementById('cookie-ja');
  var nee = document.getElementById('cookie-nee');
  var her = [].slice.call(document.querySelectorAll('.cookiebalk-open'));

  function bewaard(){
    try{ return localStorage.getItem(SLEUTEL); }catch(e){ return null; }
  }

  function toon(){ balk.classList.add('aan'); }
  function verberg(){ balk.classList.remove('aan'); }

  /* Alleen analytics_storage beweegt mee. De drie advertentiesoorten blijven
     geweigerd, ook bij akkoord, want er wordt niet geadverteerd en er is dus
     niets om toestemming voor te vragen. Dat staat ook zo in de
     privacyverklaring. */
  function zet(stand){
    if(typeof gtag !== 'undefined'){
      gtag('consent', 'update', {
        analytics_storage:  stand,
        ad_storage:         'denied',
        ad_user_data:       'denied',
        ad_personalization: 'denied'
      });
    }
    try{ localStorage.setItem(SLEUTEL, stand); }catch(e){}
    verberg();
  }

  var eerder = bewaard();
  if(eerder === 'granted') zet('granted');
  else if(eerder !== 'denied') toon();

  if(ja)  ja.addEventListener('click',  function(){ zet('granted'); });
  if(nee) nee.addEventListener('click', function(){ zet('denied');  });

  /* Herzien wist de onthouden keuze niet meteen. De balk komt terug en pas de
     knop erin legt de nieuwe keuze vast. Wie hem opent en zich bedenkt houdt
     dus wat hij had; wegklikken zonder te kiezen bestaat hier niet, want er is
     geen kruisje. Een balk die je kunt wegklikken zonder te antwoorden telt
     niet als toestemming en zou de vraag bij elke pagina terugbrengen. */
  her.forEach(function(k){
    k.addEventListener('click', function(){ toon(); });
  });
})();
