$(document).ready(function() {
    var r = Raphael('history', 900, 240)
    var rHist = r.g.linechart(0, 0, 900, 240, hist.x, hist.y,
        {nostroke: false, axis: "0 0 1 1", symbol: "x", smooth: true, shade: true, gutter: 50, width: 2})
        
    var r = Raphael('pie', 640, 300)
    var rPie = r.g.piechart(140, 140, 120, curr.values, {legend: curr.legend})
    rPie.hover(function () {
        this.sector.stop();
        this.sector.scale(1.1, 1.1, this.cx, this.cy);
        if (this.label) {
            this.label[0].stop();
            this.label[0].scale(1.5);
            this.label[1].attr({"font-weight": 800});
        }
    }, function () {
        this.sector.animate({scale: [1, 1, this.cx, this.cy]}, 500, "bounce");
        if (this.label) {
            this.label[0].animate({scale: 1}, 500, "bounce");
            this.label[1].attr({"font-weight": 400});
        }
    });
})