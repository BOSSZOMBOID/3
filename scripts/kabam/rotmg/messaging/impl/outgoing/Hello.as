package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.ByteArray;
   import flash.utils.IDataOutput;
   
   public class Hello extends OutgoingMessage
   {
       
      
      public var buildVersion:String;
      
      public var gameId:int = 0;
      
      public var guid:String;
      
      public var loginToken:String;
      
      public var keyTime:int = 0;
      
      public var key:ByteArray;
      
      public var mapJSON:String;
      
      public var cliBytes:int = 0;
      
      public function Hello(param1:uint, param2:Function)
      {
         this.key = new ByteArray();
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeUTF(this.buildVersion);
         param1.writeInt(this.gameId);
         param1.writeUTF(this.guid);
         param1.writeUTF(this.loginToken);
         param1.writeInt(this.keyTime);
         param1.writeShort(this.key.length);
         param1.writeBytes(this.key);
         param1.writeInt(this.mapJSON.length);
         param1.writeUTFBytes(this.mapJSON);
         param1.writeInt(this.cliBytes);
      }
      
      override public function toString() : String
      {
         return formatToString("HELLO","buildVersion","gameId","guid","loginToken","keyTime","key","mapJSON","cliBytes");
      }
   }
}
