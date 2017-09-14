var timer = null;

function showAlert(type, message) {
  if (timer) {
    clearTimeout(timer)
  }
  $(".alert-fixed").remove();

  $("body").append('<div class="alert alert-dismissable alert-fixed alert-' + type + '"><button aria-hidden="true" data-dismiss="alert" class="close">×</button>' + message + '</div>');

  timer = setTimeout(function() {
    $(".alert-fixed").remove();
  }, 3000);
}

$(document).ready(function() {
  $('#refresh-scores').click(function() {
    showAlert('info', 'Refreshing scores. Please wait...');

    var data = {};
    data['_csrf'] = $("input[name='_csrf']").attr('value');

    $.ajax({
      method: 'POST',
      url: '/scores',
      data: data,
      context: this,
      success: function() {
        window.location.reload();
        showAlert('success', 'Scores refreshed');
      },
      error: function() {
        showAlert('danger', 'Uh oh, butt fumble. Contact your admin.');
      }
    });
  });

  $('.select-pick').click(function() {
    var type = $(this).data('type');

    data = {
      odd_id: $(this).data('odd'),
      team_id: $(this).data('team')
    }
    data['_csrf'] = $("input[name='_csrf']").attr('value');

    $.ajax({
      method: 'POST',
      url: '/picks',
      data: data,
      context: this,
      success: function(response) {
        var klass = "#" + data['odd_id'] + " .select-pick";

        $(klass).removeClass("btn-success");
        $(klass).addClass("btn-default");

        $(this).removeClass("btn-default");
        $(this).addClass("btn-success");

        if (type === 'spread') {
          $(klass).html('<i class="fa fa-ban text-black"></i>');
          $(this).html('<i class="fa fa-check"></i>');
        }

        showAlert('success', 'Selection saved: ' + response);
      },
      error: function(response) {
        showAlert('danger', 'Uh oh, butt fumble. Contact your admin.');
      }
    });
  });
});
