var ItemTable = {

  bindEvents: function () {

    $('#settings_menu li a').bind( 'click', ItemTable.savePreferences );
    $('#privacy_link li a').bind( 'click', ItemTable.savePreferences );

    $('table.records a.delete_record').bind( 'click', ItemTable.deleteRecord );

    //add item to board
    $('#add_items').on('change', ItemTable.addItemToBoard);

  },

  savePreferences: function (e) {

    e.preventDefault();

    $.ajax({
      type: 'put',
      url: '/api/1/users/' + user_id + '/items/' + item_id + '?accesskey=' + accesskey,
      data: {
        display_type:       $('#settings_menu li a').data('display-type'),
        display_frequency:  $('#settings_menu li a').data('display-frequency'),
        privacy:            $('#privacy_link li a').data('privacy')
      }
    });

  },

  deleteRecord: function (e) {
    e.preventDefault();

    $.ajax({
      type: 'delete',
      url: '/api/1/users/' + user_id + '/items/' + item_id + '/records/' + $(e.target).attr('rel') + '?accesskey=' + accesskey,
      success: function () {
        $(e.target).parent().parent().remove();
      }
    });

    $.ajax({
      type: 'get',
      url: '/api/1/users/' + user_id + '/items/' + item_id + '/records.json?accesskey=' + accesskey,
      dataType: 'json',
      success: function (data) {

        d3.select('#graph svg')
          .datum([return_values(data)])
          .transition()
          .duration(0)
          .call(chart);

      }
    });
  },

  addItemToBoard: function (e) {
    e.preventDefault();

    $.ajax({
      type: 'post',
      url: '/api/1/users/4f68920ba85f1a0003000001/categories/' + category_id + '/items?accesskey=' + accesskey,
      data: { items: [$(this).val()] },
      success: function (data) {
        location.reload();
      }
    });
  }

};