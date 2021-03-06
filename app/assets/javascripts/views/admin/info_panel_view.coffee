Marionette = require("marionette")
_ = require("underscore")

class InfoPanelView extends Marionette.ItemView

  template: _.template("""
    <header>
      <h3>Info Panel / Placeholder</h3>
    </header>
    <p>
      Bacon ipsum dolor sit amet shankle strip steak venison turkey landjaeger pork loin salami corned beef pork belly drumstick flank. Kielbasa brisket sirloin, shank flank prosciutto venison short loin. Boudin short loin corned beef, pork chop sirloin doner short ribs pancetta spare ribs ball tip. Ribeye sausage ham swine. Pork loin biltong ham hock frankfurter, hamburger strip steak t-bone pork belly shank beef pancetta turkey landjaeger prosciutto meatloaf. Meatball leberkas landjaeger flank salami shankle shoulder swine andouille brisket kielbasa tri-tip. Bresaola boudin turkey, beef short ribs pastrami tail cow doner pork loin tenderloin chicken t-bone.
    </p>
  """)
  
module.exports = InfoPanelView