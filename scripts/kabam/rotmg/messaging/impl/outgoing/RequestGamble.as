package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class RequestGamble extends OutgoingMessage
   {
       
      
      public var name_:String;
      
      public var amount_:int;
      
      public function RequestGamble(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeUTF(this.name_);
         param1.writeInt(this.amount_);
      }
      
      override public function toString() : String
      {
         return formatToString("REQUESTGAMBLE","name_","amount_");
      }
   }
}
