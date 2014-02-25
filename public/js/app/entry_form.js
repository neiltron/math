var EntryForm = {

  bindEvents: function () {

    this.item_form_timer = '';

    $('#record_form')
      .bind( 'focusin',   this.focus )
      .bind( 'focusout',  this.unfocus )
      .bind( 'submit',    this.submit );

  },

  focus: function () {

    clearTimeout(this.item_form_timer);

    $('#record_form').addClass('active');
    $('#items').addClass('active');

  },

  unfocus: function () {

    this.item_form_timer = setTimeout(function () {

      $('#record_form').removeClass('active');
      $('#items').removeClass('active');

    }, 300);

  },

  submit: function (e) {
    e.preventDefault();

    var amount = $('#record_form #amount').val(),
        item_name = $('#record_form #item_name').val(),
        that = this;

    if (amount === '' || item_name === '') {
      return false;
    }

    EntryForm.disableSaveBtn();

    EntryForm.postFormData(amount, item_name);

  },

  disableSaveBtn: function () {
    $('#submit_item').val('Saving...').addClass('disabled');
  },

  enableSaveBtn: function () {
    $('#submit_item').val('Save').removeClass('disabled');
  },

  postFormData: function (amount, item_name) {

    var that = this;

    $.ajax({
      type: 'post',
      url: '/api/1/users/' + user_id + '/records.json',
      data: { accesskey: accesskey, item_name: item_name, amount: amount },
      success: function (e) {

        $('#amount').val('');

        that.enableSaveBtn();

      },
      error: function () {

        that.enableSaveBtn();

      }
    });
  }

};