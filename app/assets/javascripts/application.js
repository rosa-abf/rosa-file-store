//= require jquery
//= require plupload
//= require_self

!function() {
  if (window.location.protocol !== "https:" && window.location.host == "file-store.rosalinux.ru" ) {
    window.location.replace("https://file-store.rosalinux.ru");
  }
  var $search = $("#search");
  var $hash = $("#hash");
  var $search_results = $(".search_results");
  $search_results.hide();

  function searching_progress() {
    $search_results.show();
    $search_results.html("Searching...");
    $search_results.removeClass("bg-warning bg-danger bg-success");
    $search_results.addClass("bg-info");
    $search.prop('disabled', true);
  }

  function searching_success(file) {
    $search_results.removeClass("bg-info bg-warning bg-danger");
    $search_results.addClass("bg-success");
    $search_results.html("Found file: <a href=\"/api/v1/file_stores/" + file.sha1_hash +
                         "\">" + file.file_name + "</a>, by " + file.user.uname);
    $search.prop('disabled', false);
  }

  function searching_notfound() {
    $search_results.removeClass("bg-info bg-success bg-danger");
    $search_results.addClass("bg-warning");
    $search_results.html("File not found.");
    $search.prop('disabled', false);
  }

  function searching_error() {
    $search_results.removeClass("bg-info bg-success bg-warning");
    $search_results.addClass("bg-danger");
    $search_results.html("Error reading server response, retry search.");
    $search.prop('disabled', false);
  }

  $search.on('click', function() {
    if($hash.val() === "") {
      $hash.focus();
      return;
    }
    searching_progress();
    $.getJSON('/api/v1/file_stores', {
      hash: $hash.val()
    }).then(function(data) {
      if (data.length === 0) {
        searching_notfound();
      } else {
        searching_success(data[0]);
      }
    }, function() {
      searching_error();
    });
  });

  $('#search_form').on('submit', function(e) {
    e.preventDefault();
    return false;
  });

  $("#file_store_uploader").pluploadQueue({
    runtime: "html5,html4",
    multiple_queues: true,
    url: "/api/v1/upload",
    file_data_name: 'file_store[file]'
  });
}();
