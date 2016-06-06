﻿<%@ Control Language="C#" AutoEventWireup="true" CodeFile="QuickSearch.ascx.cs" Inherits="RockWeb.Plugins.org_secc.FamilyCheckin.QuickSearch" %>
<div id="signOuter">
    <div id="signInner">
        <div id="signTextOuter">
            <div id="signText">
            </div>
        </div>

        <div id="signFlowerShadow"></div>
        <div id="signFlower"></div>
    </div>
</div>
<script>
    var selectionActive=false;
    var showingWelcome=false;

    Sys.Application.add_load(function () {
        $('.tenkey a.digit').click(function () {
            if (selectionActive){
                return;
            }
            $phoneNumber = $("input[id$='tbPhone']");
            $phoneNumber.val($phoneNumber.val() + $(this).html());
        });
        $('.tenkey a.back').click(function () {
            if (selectionActive){
                return;
            }
            $phoneNumber = $("input[id$='tbPhone']");
            $phoneNumber.val($phoneNumber.val().slice(0, -1));
            if ($phoneNumber.val().length==0){
                showWelcome();
            }
        });
        $('.tenkey a.clear').click(function () {
            if (selectionActive){
                return;
            }
            $phoneNumber = $("input[id$='tbPhone']");
            $phoneNumber.val('');
            showWelcome();
        });

        // set focus to the input unless on a touch device
        var isTouchDevice = 'ontouchstart' in document.documentElement;
        if (!isTouchDevice) {
            $('.checkin-phone-entry').focus();
        }
    });

    var doSearch = function(){
        if (selectionActive){
            return;
        }
        var phoneNumber =  $("input[id$='tbPhone']").val().replace(/\D/g, '');
        var minLength = <%= minLength.ToString()%>;
        if (phoneNumber.length>=minLength){
            showSign('Searching...', true);
                
            $.ajax({
                url: "/api/org.secc/familycheckin/family/"+phoneNumber,
                dataType: "json",
                success: function(data){
                    showFamilies(data);},
                error: function(data){
                    showSign("There was an issue with the request. Please try again. If the problem continues please contact a volunteer to help you.", false, "1vw")
                }
            });
        } else {
            showSign("Please enter at least <br> <%= minLength.ToString()%> digits to search.", false, "2vw")
                    $("#familyDiv").empty();
                }
    }

            var showFamilies = function(families) {
                if (selectionActive){
                    return;
                }
                if (families.length==0){
                    var content = document.getElementById("contentDiv");
                    content.style.transform="translateX(0px)";
                    var families = document.getElementById("familyDiv");
                    families.style.transform="translateX(0px)";
                    showSign("Sorry, we could not find your phone number.",false, "2vw")
                    return;
                }else{
                    setTimeout(function(){ showSign("Select your family to continue.",false, "2.5vw")},300)

                }
                var content = document.getElementById("contentDiv");
                content.style.transform="translateX(800px)";

                familyDiv = $("#familyDiv");
                familyDiv.empty();
                families.forEach(
                    function(family){
                        var link = $("<a>");
                        link.html("<h2>"+family["Caption"] +"</h2>"+ family["SubCaption"]);
                        link.attr("id",family["Group"]["Id"]);
                        link.click(chooseFamily)
                        link.addClass("btn btn-primary btn-block familyButton");
                        familyDiv.append(link);
                    }
                );
                familyDiv.get(0).style.transform = "translateX(800px)";
            }

            var chooseFamily = function(event){
                if (selectionActive){
                    return;
                }
                selectionActive=true
                this.innerHTML = "<h2><i class='fa fa-refresh fa-spin'></i> Loading Family</h2>Please wait..."
                this.className = "btn btn-success btn-block"
            
                __doPostBack("ChooseFamily", this.id);
            }

            var signVisible=false;
            var signTimeout;
 
            var showSign = function(text, showLoading, fontSize){
                if (signVisible) {
                    hideSign();
                    if (signTimeout)clearTimeout(signTimeout);
                    signTimeout= setTimeout(function() {showSign(text,showLoading, fontSize) },100)
                    return;
                }
                signVisible=true;
                var signText = document.getElementById("signText");
                signText.innerHTML = text;
                if (fontSize) {
                    signText.style.fontSize=fontSize;
                }else {
                    signText.style.fontSize="4vw";
                }
  
                if (!showLoading) {
                    document.getElementById("signFlower").style.display="none";
                    document.getElementById("signFlowerShadow").style.display="none";
                } else {
                    document.getElementById("signFlower").style.display="block";
                    document.getElementById("signFlowerShadow").style.display="block";
                }
                var signOuter = document.getElementById("signOuter");
                signOuter.style.transform="translateY(13vw)";
                showingWelcome=false;
            }
 
            var hideSign = function(){
                signVisible=false;
                var signOuter = document.getElementById("signOuter");
                signOuter.style.transform="translateY(-15vw)";
                showingWelcome=false;
            }

            var showWelcome =function(){
                if (showingWelcome){
                    return;
                }
                showSign("<span style='font-size:3vw'>Welcome!</span><br>Please enter your phone number.", false, "1.5vw")
                var content = document.getElementById("contentDiv");
                content.style.transform="translateX(0px)";
                var families = document.getElementById("familyDiv");
                families.style.transform="translateX(0px)";

                setTimeout(function(){showingWelcome=true},150);
            }
</script>

<asp:UpdatePanel ID="upContent" runat="server" CssClass="">
    <ContentTemplate>



        <asp:PlaceHolder ID="phScript" runat="server"></asp:PlaceHolder>

        <Rock:HiddenFieldWithClass ID="hfRefreshTimerSeconds" runat="server" CssClass="js-refresh-timer-seconds" />

        <span style="display: none">
            <asp:LinkButton ID="lbRefresh" runat="server" OnClick="lbRefresh_Click"></asp:LinkButton>
            <asp:Label ID="lblActiveWhen" runat="server" CssClass="active-when" />
        </span>

        <%-- Panel for no schedules --%>
        <asp:Panel ID="pnlNotActive" runat="server">
            <div class="checkin-header">
                <h1>Check-in Is Not Active</h1>
            </div>

            <div class="checkin-body">

                <div class="checkin-scroll-panel">
                    <div class="scroller">
                        <p>There are no more check-in schedules today.</p>

                    </div>
                </div>

            </div>
        </asp:Panel>

        <%-- Panel for schedule not active yet --%>
        <asp:Panel ID="pnlNotActiveYet" runat="server">
            <div class="checkin-header">
                <h1>Check-in Is Not Active Yet</h1>
            </div>

            <div class="checkin-body">

                <div class="checkin-scroll-panel">
                    <div class="scroller">

                        <p>This kiosk is not active yet.  Countdown until active: <span class="countdown-timer"></span></p>
                        <asp:HiddenField ID="hfActiveTime" runat="server" />

                    </div>
                </div>

            </div>
        </asp:Panel>

        <%-- Panel for location closed --%>
        <asp:Panel ID="pnlClosed" runat="server">
            <div class="checkin-header checkin-closed-header">
                <h1>Closed</h1>
            </div>

            <div class="checkin-body checkin-closed-body">
                <div class="checkin-scroll-panel">
                    <div class="scroller">
                        <p>This location is currently closed.</p>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- Panel for active checkin --%>
        <asp:Panel ID="pnlActive" runat="server" CssClass="search-panel">
            <div class="checkin-body search-body">
                <div class="scroller">
                    <div class="container">
                        <div class="row">
                            <div class="col-xs-4">
                                <div class="checkin-search-body">

                                    <asp:Panel ID="pnlSearchPhone" runat="server">
                                        <Rock:RockTextBox ID="tbPhone" MaxLength="10" CssClass="checkin-phone-entry" runat="server"
                                            autocomplete="off" />
                                        <div class="tenkey checkin-phone-keypad">
                                            <div>
                                                <a href="#" class="btn btn-default btn-lg digit">1</a>
                                                <a href="#" class="btn btn-default btn-lg digit">2</a>
                                                <a href="#" class="btn btn-default btn-lg digit">3</a>
                                            </div>
                                            <div>
                                                <a href="#" class="btn btn-default btn-lg digit">4</a>
                                                <a href="#" class="btn btn-default btn-lg digit">5</a>
                                                <a href="#" class="btn btn-default btn-lg digit">6</a>
                                            </div>
                                            <div>
                                                <a href="#" class="btn btn-default btn-lg digit">7</a>
                                                <a href="#" class="btn btn-default btn-lg digit">8</a>
                                                <a href="#" class="btn btn-default btn-lg digit">9</a>
                                            </div>
                                            <div>
                                                <a href="#" class="btn btn-default btn-lg command back">Back</a>
                                                <a href="#" class="btn btn-default btn-lg digit">0</a>
                                                <a href="#" class="btn btn-default btn-lg command clear">Clear</a>
                                            </div>
                                        </div>
                                        <a href="#" class="btn btn-primary btn-lg search-button" onclick="doSearch()">Search</a>
                                    </asp:Panel>

                                </div>
                            </div>
                            <div class="col-xs-8" id="contentContainer">
                                <div id="contentDiv">
                                    <asp:Literal ID="ltContent" runat="server" />
                                </div>
                                <div id="familyDiv"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>

<script>
    showWelcome();
</script>
