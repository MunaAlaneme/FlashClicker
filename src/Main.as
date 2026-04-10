/* run with /Applications/ApacheFlex4.16.1/bin/mxmlc \
-source-path+=src \
-library-path+=lib \
-output bin/Main.swf \
src/Main.as

also use this if you want to build:
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)                                                              
export PATH=$JAVA_HOME/bin:$PATH

java -jar /Users/munaalaneme/.vscode/extensions/bowlerhatllc.vscode-as3mxml-1.24.0/bin/asconfigc.jar --sdk /Applications/AIRSDK_51.3.1 --debug=true --project asconfig.json --unpackage-anes=true
"/Volumes/PortableSSD/Default Folder/jdk-26.jdk/Contents/Home/bin/java" -jar /Users/munaalaneme/.vscode/extensions/bowlerhatllc.vscode-as3mxml-1.24.0/bin/asconfigc.jar --sdk /Applications/AIRSDK_51.3.1 --debug=true --project asconfig.json --unpackage-anes=true
"/Volumes/PortableSSD/Default Folder/jdk-21.0.10.jdk/Contents/Home/bin/java" -jar /Users/munaalaneme/.vscode/extensions/bowlerhatllc.vscode-as3mxml-1.24.0/bin/asconfigc.jar --sdk /Applications/AIRSDK_51.3.1 --debug=true --project "/Volumes/PortableSSD/Default Folder/Flash game/asconfig.json" --unpackage-anes=true


https://flex.apache.org/community-3rdparty.html
https://www.youtube.com/watch?v=MVBPOAnaYZc
https://www.youtube.com/watch?v=Yp4Fpexkads
https://www.youtube.com/watch?v=S9qX-i1qr9g
*/


package
{
    import starling.core.Starling;
    import flash.display.Sprite;
    import starling.events.Event;
    import starling.events.ResizeEvent;
    import flash.geom.Rectangle;
    import flash.display.*;
    import starling.utils.*;

    [SWF(width="1280", height="720", frameRate="0", backgroundColor="#808080")]
    public class Main extends Sprite
    {
        private var _starling:Starling;
        private static var _root:Game;
        public static function get root():Game
        {
            return _root;
        }

        public function Main()
        {
            trace("Hello World");
            _starling = new Starling(Game, stage);
            _starling.addEventListener(Event.ROOT_CREATED, onRootCreated);
            // _starling.showStats = true;
            _starling.supportHighResolutions = true;
            _starling.showStats = true;
            _starling.skipUnchangedFrames = true;
            _starling.start();
            _starling.stage.addEventListener(Event.RESIZE, onStageResize);
        }

        private function onRootCreated(event:Event, root_instance:Game):void
        {
            _starling.removeEventListener(Event.ROOT_CREATED, onRootCreated);
            _root = root_instance;
        }

        private function onStageResize(event:ResizeEvent):void
        {
            _starling.viewPort = RectangleUtil.fit(
                    new Rectangle(0, 0, 1280, 720),
                    new Rectangle(0, 0, event.width, event.height)
                );
        }
    }
}