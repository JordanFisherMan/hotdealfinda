// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require_tree .

var filter = document.getElementById("js-filter");
if (typeof filter != "undefined" && filter != null) {
  // Where el is the DOM element you'd like to test for visibility
  function isHidden(el) {
    return el.offsetParent === null;
  }
  var categories = document.getElementById("js-categories");
  filter.addEventListener("click", function () {
    if (isHidden(categories)) {
      categories.style.display = "block";
    } else {
      categories.style.display = "none";
    }
  });
}

document.addEventListener("DOMContentLoaded", function () {
  var lazyImages = [].slice.call(document.querySelectorAll("img.lazy"));
  if ("IntersectionObserver" in window) {
    let lazyImageObserver = new IntersectionObserver(function (
      entries,
      observer
    ) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          let lazyImage = entry.target;
          lazyImage.src = lazyImage.dataset.src;
          // lazyImage.srcset = lazyImage.dataset.srcset;
          lazyImage.classList.remove("lazy");
          lazyImage.removeAttribute('data-src');
          lazyImageObserver.unobserve(lazyImage);
        }
      });
    });
    lazyImages.forEach(function (lazyImage) {
      lazyImageObserver.observe(lazyImage);
    });
  } else {
    // Possibly fall back to a more compatible method here
  }
});

// get prices prices after page load
(function getPrices() {
  var xhttp;
  var prices = document.getElementsByClassName("js-price");
  for (var i = 0; i < prices.length; i++) {
      xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function () {
          if (this.readyState == 4 && this.status == 200) {
              var json = JSON.parse(this.responseText);
              var deal = document.getElementById(json.Item.ItemID.toString());
              deal.innerHTML = "$" + json.Item.ConvertedCurrentPrice.Value.toFixed(2);
          }
      };
      xhttp.open("GET", "/get_live_price?id=" + prices[i].id, true);
      xhttp.send();
  }
})();