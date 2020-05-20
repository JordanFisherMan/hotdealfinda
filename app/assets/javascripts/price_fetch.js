(function loadDoc() {
    var xhttp;
    var prices = document.getElementsByClassName("js-price");
    for (var i = 0; i < prices.length; i++) {
        xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function () {
            if (this.readyState == 4 && this.status == 200) {
                var json = JSON.parse(this.responseText);
                var deal = document.getElementById(json.Item.ItemID.toString());
                deal.innerHTML = "$" + json.Item.ConvertedCurrentPrice.Value;
            }
        };
        xhttp.open("GET", "/get_live_price?id=" + prices[i].id, true);
        xhttp.send();
    }
})();