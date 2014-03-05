var items = [];
var records = {};
var chart;

window.addEventListener('load', function() {
  new FastClick(document.body);
}, false);

Sidebar.bindEvents();
EntryForm.bindEvents();
ItemTable.bindEvents();

$(document).ready(function ($) {
  isNumber = function (value) {
    if ((undefined === value) || (null === value)) {
      return false;
    }
    if (typeof value == 'number') {
      return true;
    }
    return !isNaN(value - 0);
  };

  drawGraphs();
});

function drawGraphs () {
  $('div.record_display').each(function (i, el) {

    var el = $(el),
        item_id = el.data('item-id'),
        category_id = el.data('category-id'),
        item_type = 'items';

    if (item_id === null) {
      item_id = category_id;
      item_type = 'categories';
    }

    d3.json('/api/1/users/' + user_id + '/' + item_type + '/' + item_id + '/records.json?accesskey=' + accesskey, function(data) {
      nv.addGraph(function() {
        //append legend dots to the items table
        if (category_id !== null) {
          $('table.records tbody tr').each(function(i, item) {
            $(item).find('td').first().prepend("<td><span style='height:10px;width:10px;display:block;float:left;border-radius:5px;margin:5px 5px 0 0;background:" + line_colors[i] + "'></span></td>");
          });
        }

        d3.select('#chart_' + item_id + ' svg')
          .datum([return_values(data)[0]])
          .transition().duration(500)
          .call(prepareLineGraph());

        //TODO: Figure out a good way to do this automatically
        nv.utils.windowResize(chart.update);
      });
    });
  });
}

function prepareLineGraph () {
  chart = nv.models.lineChart()
            .width($('body').width())
            .tooltipContent(function (key, x, y, e, graph) {
              var tooltip = [];

              if (key !== '' && typeof key !== 'undefined') {
                tooltip.push('<p>' + key + '</p>');
              }

              tooltip.push('<p>' + y + ' at ' + x + '</p>');

              return tooltip;
            });

  chart.xAxis
    .tickFormat(function(d) {
      return d3.time.format('%_m/%d')(new Date(d * 1000));
    });

  chart.yAxis
    .tickFormat(d3.format());

  return chart;
}

function return_values (data) {
  return $.map(data.values, function (item, i) {
    var values = $(item.values).map(function(j, value) {
      if (isNumber(value[1])) {
        key = typeof data.key === 'undefined' ? data.values[i].key : data.key;

        return { key: key, x: value[0], y: value[1] };
      }
    });


    return {
      area: true,
      values: values,
      color: line_colors[i] || '#faa',
      key: data.values[i].key
    };
  })
}

var line_colors = [
  '#faa',
  '#f66',
  '#333',
  '#366',
  '#399',
  '#9cc'
];