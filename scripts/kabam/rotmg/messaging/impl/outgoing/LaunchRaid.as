package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class LaunchRaid extends OutgoingMessage
   {
       
      
      public var raidId_:int;
      
      public var ultra_:Boolean;
      
      public function LaunchRaid(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.raidId_);
         param1.writeBoolean(this.ultra_);
      }
      
      override public function toString() : String
      {
         return formatToString("LAUNCHRAID","raidId_","ultra_");
      }
   }
}
