#

jscode <- '
$(function() {
  var $els = $("[data-proxy-click]");
  $.each(
    $els,
    function(idx, el) {
      var $el = $(el);
      var $proxy = $("#" + $el.data("proxyClick"));
      $el.keydown(function (e) {
        if (e.keyCode == 13) {
          $proxy.click();
        }
      });
    }
  );
});
'

# Add code to query whether users want to leave the page
# Prevents accidental loss of work if browser back button is used
prevent_back <- 'window.onbeforeunload = function() { return "Please use the button on the webpage"; };'

# Read information on the most recent medRxivr snapshot
snapshot_info <- paste0("Using medRxiv snapshot - ",
                        readLines(
                          paste0(
                            "https://raw.githubusercontent.com/",
                            "mcguinlu/",
                            "autosynthesis/master/data/timestamp.txt"
                          )
                        ))
