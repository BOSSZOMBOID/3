package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class AcceptPartyInvite extends OutgoingMessage
   {
       
      
      public var From_:String;
      
      public function AcceptPartyInvite(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeUTF(From_);
      }
      
      override public function toString() : String
      {
         return formatToString("ACCEPTPARTYINVITE","From_");
      }
   }
}
