var msg =""
var activeRow = 0;
$(function(){
    $("a.editRow").live("click",function(){
      var url = $(this).attr("data-url");
      var id  = $(this).attr("data-rel");

      if(activeRow){
          alert("Please complete the current editing row , then start new editing");
          return false;
      }
      getEditForm(url, id);

      return false;
    });
 });

function roleChange(select){
   var place_code =  $(select).parent().prev().children().get(0);
   if( $(select).val() != "default"){
       place_code.value = ""
       place_code.disabled = true;
   }
   else{
       place_code.disabled = false;
   }

}

function showNotice(){
  $("#div_notice").html(msg);
}

function getEditForm(url, id){
  $.ajax({
          url: url,
          method: "get",
          success: function(responseText, status, responseObj){
             updateRow(id, responseText);
             showNotice();
             activeRow = id;
             addForm(false);
          }
  });
}

function updateRow(id,html){
    $("#tr_"+ id ).html(html);
}

function addForm(show){
   if(show){
      $("#inputRow").fadeIn("slow");
      //$("#inputRow").show();
   }
   else{
      $("#inputRow").fadeOut("slow");
      //$("#inputRow").hide();
   }

}
