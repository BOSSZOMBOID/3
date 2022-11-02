package kabam.rotmg.messaging.impl
{
   import com.company.assembleegameclient.account.ui.Unboxing.UnboxResultBox;
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.game.events.GuildResultEvent;
   import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
   import com.company.assembleegameclient.game.events.NameResultEvent;
   import com.company.assembleegameclient.game.events.ReconnectEvent;
   import com.company.assembleegameclient.map.AbstractMap;
   import com.company.assembleegameclient.map.GroundLibrary;
   import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
   import com.company.assembleegameclient.objects.Container;
   import com.company.assembleegameclient.objects.FlashDescription;
   import com.company.assembleegameclient.objects.Friend;
   import com.company.assembleegameclient.objects.GameObject;
   import com.company.assembleegameclient.objects.Merchant;
   import com.company.assembleegameclient.objects.NameChanger;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.objects.ObjectProperties;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.objects.Projectile;
   import com.company.assembleegameclient.objects.ProjectileProperties;
   import com.company.assembleegameclient.objects.SellableObject;
   import com.company.assembleegameclient.objects.animation.Animations;
   import com.company.assembleegameclient.objects.particles.AOEEffect;
   import com.company.assembleegameclient.objects.particles.BurstEffect;
   import com.company.assembleegameclient.objects.particles.CollapseEffect;
   import com.company.assembleegameclient.objects.particles.ConeBlastEffect;
   import com.company.assembleegameclient.objects.particles.FlowEffect;
   import com.company.assembleegameclient.objects.particles.HealEffect;
   import com.company.assembleegameclient.objects.particles.LightningEffect;
   import com.company.assembleegameclient.objects.particles.LineEffect;
   import com.company.assembleegameclient.objects.particles.NovaEffect;
   import com.company.assembleegameclient.objects.particles.ParticleEffect;
   import com.company.assembleegameclient.objects.particles.PoisonEffect;
   import com.company.assembleegameclient.objects.particles.RingEffect;
   import com.company.assembleegameclient.objects.particles.RisingFuryEffect;
   import com.company.assembleegameclient.objects.particles.ShockeeEffect;
   import com.company.assembleegameclient.objects.particles.ShockerEffect;
   import com.company.assembleegameclient.objects.particles.StreamEffect;
   import com.company.assembleegameclient.objects.particles.TeleportEffect;
   import com.company.assembleegameclient.objects.particles.ThrowEffect;
   import com.company.assembleegameclient.objects.thrown.ThrowProjectileEffect;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.sound.Music;
   import com.company.assembleegameclient.sound.SoundEffectLibrary;
   import com.company.assembleegameclient.ui.PicView;
   import com.company.assembleegameclient.ui.dialogs.Dialog;
   import com.company.assembleegameclient.ui.dialogs.NotEnoughFameDialog;
   import com.company.assembleegameclient.ui.lootNotification.LootNotification;
   import com.company.assembleegameclient.ui.panels.GambleRequestPanel;
   import com.company.assembleegameclient.ui.panels.GuildInvitePanel;
   import com.company.assembleegameclient.ui.panels.PartyInvitePanel;
   import com.company.assembleegameclient.ui.panels.TradeRequestPanel;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.util.MoreStringUtil;
   import com.company.util.Random;
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.rsa.RSAKey;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.util.Base64;
   import com.hurlant.util.der.PEM;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import kabam.lib.net.api.MessageMap;
   import kabam.lib.net.api.MessageProvider;
   import kabam.lib.net.impl.Message;
   import kabam.lib.net.impl.SocketServer;
   import kabam.rotmg.account.core.Account;
   import kabam.rotmg.account.core.view.PurchaseConfirmationDialog;
   import kabam.rotmg.arena.control.ArenaDeathSignal;
   import kabam.rotmg.arena.control.ImminentArenaWaveSignal;
   import kabam.rotmg.arena.model.CurrentArenaRunModel;
   import kabam.rotmg.arena.view.BattleSummaryDialog;
   import kabam.rotmg.arena.view.ContinueOrQuitDialog;
   import kabam.rotmg.chat.model.ChatMessage;
   import kabam.rotmg.classes.model.CharacterClass;
   import kabam.rotmg.classes.model.CharacterSkin;
   import kabam.rotmg.classes.model.CharacterSkinState;
   import kabam.rotmg.classes.model.ClassesModel;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.death.control.HandleDeathSignal;
   import kabam.rotmg.death.control.ZombifySignal;
   import kabam.rotmg.dialogs.control.CloseDialogsSignal;
   import kabam.rotmg.dialogs.control.OpenDialogSignal;
   import kabam.rotmg.game.focus.control.SetGameFocusSignal;
   import kabam.rotmg.game.model.GameModel;
   import kabam.rotmg.game.signals.AddSpeechBalloonSignal;
   import kabam.rotmg.game.signals.AddTextLineSignal;
   import kabam.rotmg.game.signals.GiftStatusUpdateSignal;
   import kabam.rotmg.game.signals.UpdateAlertStatusDisplaySignal;
   import kabam.rotmg.maploading.signals.ChangeMapSignal;
   import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
   import kabam.rotmg.market.MarketItemsResultSignal;
   import kabam.rotmg.market.MarketResultSignal;
   import kabam.rotmg.messaging.impl.data.GroundTileData;
   import kabam.rotmg.messaging.impl.data.MarketOffer;
   import kabam.rotmg.messaging.impl.data.ObjectData;
   import kabam.rotmg.messaging.impl.data.ObjectStatusData;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   import kabam.rotmg.messaging.impl.data.StatData;
   import kabam.rotmg.messaging.impl.incoming.AccountList;
   import kabam.rotmg.messaging.impl.incoming.AllyShoot;
   import kabam.rotmg.messaging.impl.incoming.Aoe;
   import kabam.rotmg.messaging.impl.incoming.BuyResult;
   import kabam.rotmg.messaging.impl.incoming.ClientStat;
   import kabam.rotmg.messaging.impl.incoming.ConditionEffectTime;
   import kabam.rotmg.messaging.impl.incoming.CreateSuccess;
   import kabam.rotmg.messaging.impl.incoming.Damage;
   import kabam.rotmg.messaging.impl.incoming.Death;
   import kabam.rotmg.messaging.impl.incoming.EnemyShoot;
   import kabam.rotmg.messaging.impl.incoming.Failure;
   import kabam.rotmg.messaging.impl.incoming.File;
   import kabam.rotmg.messaging.impl.incoming.GambleStart;
   import kabam.rotmg.messaging.impl.incoming.GlobalNotification;
   import kabam.rotmg.messaging.impl.incoming.Goto;
   import kabam.rotmg.messaging.impl.incoming.GuildResult;
   import kabam.rotmg.messaging.impl.incoming.HomeDepotResult;
   import kabam.rotmg.messaging.impl.incoming.InvResult;
   import kabam.rotmg.messaging.impl.incoming.InvitedToGuild;
   import kabam.rotmg.messaging.impl.incoming.KeyInfoResponse;
   import kabam.rotmg.messaging.impl.incoming.LootNotification;
   import kabam.rotmg.messaging.impl.incoming.MapInfo;
   import kabam.rotmg.messaging.impl.incoming.MarketResult;
   import kabam.rotmg.messaging.impl.incoming.NameResult;
   import kabam.rotmg.messaging.impl.incoming.NewTick;
   import kabam.rotmg.messaging.impl.incoming.Notification;
   import kabam.rotmg.messaging.impl.incoming.PartyRequest;
   import kabam.rotmg.messaging.impl.incoming.PasswordPrompt;
   import kabam.rotmg.messaging.impl.incoming.Pic;
   import kabam.rotmg.messaging.impl.incoming.Ping;
   import kabam.rotmg.messaging.impl.incoming.PlaySound;
   import kabam.rotmg.messaging.impl.incoming.QuestFetchResponse;
   import kabam.rotmg.messaging.impl.incoming.QuestObjId;
   import kabam.rotmg.messaging.impl.incoming.QuestRedeemResponse;
   import kabam.rotmg.messaging.impl.incoming.QueuePing;
   import kabam.rotmg.messaging.impl.incoming.Reconnect;
   import kabam.rotmg.messaging.impl.incoming.ReskinUnlock;
   import kabam.rotmg.messaging.impl.incoming.SendAspectData;
   import kabam.rotmg.messaging.impl.incoming.ServerFull;
   import kabam.rotmg.messaging.impl.incoming.ServerPlayerShoot;
   import kabam.rotmg.messaging.impl.incoming.SetFocus;
   import kabam.rotmg.messaging.impl.incoming.ShowEffect;
   import kabam.rotmg.messaging.impl.incoming.ShowTrials;
   import kabam.rotmg.messaging.impl.incoming.SorForge;
   import kabam.rotmg.messaging.impl.incoming.SwitchMusic;
   import kabam.rotmg.messaging.impl.incoming.TradeAccepted;
   import kabam.rotmg.messaging.impl.incoming.TradeChanged;
   import kabam.rotmg.messaging.impl.incoming.TradeDone;
   import kabam.rotmg.messaging.impl.incoming.TradeRequested;
   import kabam.rotmg.messaging.impl.incoming.TradeStart;
   import kabam.rotmg.messaging.impl.incoming.UnboxResultPacket;
   import kabam.rotmg.messaging.impl.incoming.Update;
   import kabam.rotmg.messaging.impl.incoming.VerifyEmail;
   import kabam.rotmg.messaging.impl.incoming.arena.ArenaDeath;
   import kabam.rotmg.messaging.impl.incoming.arena.ImminentArenaWave;
   import kabam.rotmg.messaging.impl.outgoing.AcceptPartyInvite;
   import kabam.rotmg.messaging.impl.outgoing.AcceptTrade;
   import kabam.rotmg.messaging.impl.outgoing.AlertNotice;
   import kabam.rotmg.messaging.impl.outgoing.AoeAck;
   import kabam.rotmg.messaging.impl.outgoing.Buy;
   import kabam.rotmg.messaging.impl.outgoing.CancelTrade;
   import kabam.rotmg.messaging.impl.outgoing.ChangeGuildRank;
   import kabam.rotmg.messaging.impl.outgoing.ChangeTrade;
   import kabam.rotmg.messaging.impl.outgoing.CheckCredits;
   import kabam.rotmg.messaging.impl.outgoing.ChooseName;
   import kabam.rotmg.messaging.impl.outgoing.Create;
   import kabam.rotmg.messaging.impl.outgoing.CreateGuild;
   import kabam.rotmg.messaging.impl.outgoing.EditAccountList;
   import kabam.rotmg.messaging.impl.outgoing.EnemyHit;
   import kabam.rotmg.messaging.impl.outgoing.EnterArena;
   import kabam.rotmg.messaging.impl.outgoing.Escape;
   import kabam.rotmg.messaging.impl.outgoing.ForgeItem;
   import kabam.rotmg.messaging.impl.outgoing.GoToQuestRoom;
   import kabam.rotmg.messaging.impl.outgoing.GotoAck;
   import kabam.rotmg.messaging.impl.outgoing.GroundDamage;
   import kabam.rotmg.messaging.impl.outgoing.GroundTeleporter;
   import kabam.rotmg.messaging.impl.outgoing.GuildInvite;
   import kabam.rotmg.messaging.impl.outgoing.GuildRemove;
   import kabam.rotmg.messaging.impl.outgoing.Hello;
   import kabam.rotmg.messaging.impl.outgoing.HomeDepotInteraction;
   import kabam.rotmg.messaging.impl.outgoing.InvDrop;
   import kabam.rotmg.messaging.impl.outgoing.InvSwap;
   import kabam.rotmg.messaging.impl.outgoing.JoinGuild;
   import kabam.rotmg.messaging.impl.outgoing.KeyInfoRequest;
   import kabam.rotmg.messaging.impl.outgoing.LaunchRaid;
   import kabam.rotmg.messaging.impl.outgoing.Load;
   import kabam.rotmg.messaging.impl.outgoing.LockItem;
   import kabam.rotmg.messaging.impl.outgoing.MarkRequest;
   import kabam.rotmg.messaging.impl.outgoing.MarketCommand;
   import kabam.rotmg.messaging.impl.outgoing.Move;
   import kabam.rotmg.messaging.impl.outgoing.OtherHit;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   import kabam.rotmg.messaging.impl.outgoing.PlayerHit;
   import kabam.rotmg.messaging.impl.outgoing.PlayerShoot;
   import kabam.rotmg.messaging.impl.outgoing.PlayerText;
   import kabam.rotmg.messaging.impl.outgoing.Pong;
   import kabam.rotmg.messaging.impl.outgoing.PotionStorageInteraction;
   import kabam.rotmg.messaging.impl.outgoing.QoLAction;
   import kabam.rotmg.messaging.impl.outgoing.QuestRedeem;
   import kabam.rotmg.messaging.impl.outgoing.QueuePong;
   import kabam.rotmg.messaging.impl.outgoing.RefreshMission;
   import kabam.rotmg.messaging.impl.outgoing.RenameItem;
   import kabam.rotmg.messaging.impl.outgoing.RequestGamble;
   import kabam.rotmg.messaging.impl.outgoing.RequestPartyInvite;
   import kabam.rotmg.messaging.impl.outgoing.RequestTrade;
   import kabam.rotmg.messaging.impl.outgoing.Reskin;
   import kabam.rotmg.messaging.impl.outgoing.SetCondition;
   import kabam.rotmg.messaging.impl.outgoing.ShootAck;
   import kabam.rotmg.messaging.impl.outgoing.SorForgeRequest;
   import kabam.rotmg.messaging.impl.outgoing.SquareHit;
   import kabam.rotmg.messaging.impl.outgoing.Teleport;
   import kabam.rotmg.messaging.impl.outgoing.TrialsRequest;
   import kabam.rotmg.messaging.impl.outgoing.UnboxRequest;
   import kabam.rotmg.messaging.impl.outgoing.UseItem;
   import kabam.rotmg.messaging.impl.outgoing.UsePortal;
   import kabam.rotmg.minimap.control.UpdateGameObjectTileSignal;
   import kabam.rotmg.minimap.control.UpdateGroundTileSignal;
   import kabam.rotmg.minimap.model.UpdateGroundTileVO;
   import kabam.rotmg.questrewards.controller.QuestFetchCompleteSignal;
   import kabam.rotmg.questrewards.controller.QuestRedeemCompleteSignal;
   import kabam.rotmg.queue.control.ShowQueueSignal;
   import kabam.rotmg.queue.control.UpdateQueueSignal;
   import kabam.rotmg.servers.api.Server;
   import kabam.rotmg.sorForge.SorForgeModal;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.trialsMenu.TrialsPanel;
   import kabam.rotmg.ui.model.Key;
   import kabam.rotmg.ui.model.UpdateGameObjectTileVO;
   import kabam.rotmg.ui.signals.ShowHideKeyUISignal;
   import kabam.rotmg.ui.signals.ShowKeySignal;
   import kabam.rotmg.ui.signals.UpdateBackpackTabSignal;
   import kabam.rotmg.ui.signals.UpdateMarkTabSignal;
   import kabam.rotmg.ui.view.NotEnoughGoldDialog;
   import kabam.rotmg.ui.view.TitleView;
   import org.osflash.signals.Signal;
   import org.swiftsuspenders.Injector;
   import robotlegs.bender.framework.api.ILogger;
   import valor.ItemData;
   import valor.battlePass.BattlePassModel;
   import valor.battlePass.missions.Mission;
   import valor.battlePass.packets.ClaimBattlePassItem;
   import valor.battlePass.packets.MissionsReceive;
   import valor.battlePass.packets.RespriteItem;
   import valor.battlePass.resprites.RespriteData;
   
   public class GameServerConnectionConcrete
   {
      
      public static const FAILURE:int = 0;
      
      public static const CREATE_SUCCESS:int = 81;
      
      public static const CREATE:int = 12;
      
      public static const PLAYERSHOOT:int = 66;
      
      public static const MOVE:int = 16;
      
      public static const PLAYERTEXT:int = 47;
      
      public static const TEXT:int = 96;
      
      public static const SERVERPLAYERSHOOT:int = 92;
      
      public static const DAMAGE:int = 97;
      
      public static const UPDATE:int = 42;
      
      public static const UPDATEACK:int = 91;
      
      public static const NOTIFICATION:int = 33;
      
      public static const NEWTICK:int = 68;
      
      public static const INVSWAP:int = 25;
      
      public static const USEITEM:int = 1;
      
      public static const SHOWEFFECT:int = 38;
      
      public static const HELLO:int = 9;
      
      public static const GOTO:int = 30;
      
      public static const INVDROP:int = 18;
      
      public static const INVRESULT:int = 63;
      
      public static const RECONNECT:int = 14;
      
      public static const PING:int = 85;
      
      public static const PONG:int = 64;
      
      public static const MAPINFO:int = 74;
      
      public static const LOAD:int = 26;
      
      public static const PIC:int = 46;
      
      public static const SETCONDITION:int = 60;
      
      public static const TELEPORT:int = 45;
      
      public static const USEPORTAL:int = 6;
      
      public static const DEATH:int = 83;
      
      public static const BUY:int = 93;
      
      public static const BUYRESULT:int = 50;
      
      public static const AOE:int = 89;
      
      public static const GROUNDDAMAGE:int = 98;
      
      public static const PLAYERHIT:int = 10;
      
      public static const ENEMYHIT:int = 19;
      
      public static const AOEACK:int = 77;
      
      public static const SHOOTACK:int = 35;
      
      public static const OTHERHIT:int = 57;
      
      public static const SQUAREHIT:int = 13;
      
      public static const GOTOACK:int = 79;
      
      public static const EDITACCOUNTLIST:int = 62;
      
      public static const ACCOUNTLIST:int = 44;
      
      public static const QUESTOBJID:int = 28;
      
      public static const CHOOSENAME:int = 23;
      
      public static const NAMERESULT:int = 22;
      
      public static const CREATEGUILD:int = 95;
      
      public static const GUILDRESULT:int = 82;
      
      public static const GUILDREMOVE:int = 49;
      
      public static const GUILDINVITE:int = 41;
      
      public static const ALLYSHOOT:int = 36;
      
      public static const ENEMYSHOOT:int = 52;
      
      public static const REQUESTTRADE:int = 34;
      
      public static const TRADEREQUESTED:int = 80;
      
      public static const TRADESTART:int = 31;
      
      public static const CHANGETRADE:int = 55;
      
      public static const TRADECHANGED:int = 4;
      
      public static const ACCEPTTRADE:int = 3;
      
      public static const CANCELTRADE:int = 39;
      
      public static const TRADEDONE:int = 94;
      
      public static const TRADEACCEPTED:int = 78;
      
      public static const CLIENTSTAT:int = 75;
      
      public static const CHECKCREDITS:int = 20;
      
      public static const ESCAPE:int = 87;
      
      public static const FILE:int = 56;
      
      public static const INVITEDTOGUILD:int = 58;
      
      public static const JOINGUILD:int = 27;
      
      public static const CHANGEGUILDRANK:int = 11;
      
      public static const PLAYSOUND:int = 59;
      
      public static const GLOBAL_NOTIFICATION:int = 24;
      
      public static const RESKIN:int = 15;
      
      public static const NEW_ABILITY:int = 21;
      
      public static const ENTER_ARENA:int = 48;
      
      public static const IMMINENT_ARENA_WAVE:int = 5;
      
      public static const ARENA_DEATH:int = 17;
      
      public static const ACCEPT_ARENA_DEATH:int = 84;
      
      public static const VERIFY_EMAIL:int = 61;
      
      public static const RESKIN_UNLOCK:int = 40;
      
      public static const PASSWORD_PROMPT:int = 69;
      
      public static const QUEST_FETCH_ASK:int = 51;
      
      public static const QUEST_REDEEM:int = 37;
      
      public static const QUEST_FETCH_RESPONSE:int = 65;
      
      public static const QUEST_REDEEM_RESPONSE:int = 88;
      
      public static const SERVER_FULL:int = 110;
      
      public static const QUEUE_PING:int = 111;
      
      public static const QUEUE_PONG:int = 112;
      
      public static const MARKET_COMMAND:int = 99;
      
      public static const QUEST_ROOM_MSG:int = 155;
      
      public static const KEY_INFO_REQUEST:int = 151;
      
      public static const KEY_INFO_RESPONSE:int = 152;
      
      public static const MARKET_RESULT:int = 100;
      
      public static const SET_FOCUS:int = 108;
      
      public static const SWITCH_MUSIC:int = 106;
      
      public static const LAUNCH_RAID:int = 156;
      
      public static const SORFORGE:int = 158;
      
      public static const SORFORGEREQUEST:int = 159;
      
      public static const FORGEITEM:int = 160;
      
      public static const UNBOXREQUEST:int = 161;
      
      public static const UNBOXRESULT:int = 162;
      
      public static const ALERTNOTICE:int = 163;
      
      public static const MARKREQUEST:int = 164;
      
      public static const QOLACTION:int = 165;
      
      public static const GAMBLESTART:int = 166;
      
      public static const REQUESTGAMBLE:int = 167;
      
      public static const REQUESTPARTYINVITE:int = 168;
      
      public static const PARTYREQUEST:int = 169;
      
      public static const PARTYACCEPTED:int = 170;
      
      public static const LOOTNOTIFICATION:int = 171;
      
      public static const SHOWTRIALS:int = 172;
      
      public static const TRIALSREQUEST:int = 173;
      
      public static const POTION_STORAGE_INTERACTION:int = 174;
      
      public static const RENAME_ITEM_MESSAGE:int = 175;
      
      public static const HOMEDEPOTINTERACTION:int = 176;
      
      public static const HOMEDEPOTINTERACTIONRESULT:int = 177;
      
      public static const GROUNDTELEPORTER:int = 178;
      
      public static const CLAIM_BATTLE_PASS_ITEM:int = 179;
      
      public static const MISSIONS_RECEIVE:int = 180;
      
      public static const RESPRITE_ITEM:int = 181;
      
      public static const LOCK_ITEM:int = 182;
      
      public static const SEND_ASPECT_DATA:int = 183;
      
      public static const REFRESH_MISSION:int = 184;
      
      public static const COND_EFF_TIME:int = 185;
      
      public static var instance:GameServerConnectionConcrete;
      
      private static const TO_MILLISECONDS:int = 1000;
      
      public static var condEffTimers:Dictionary;
       
      
      public var changeMapSignal:Signal;
      
      public var gs:GameSprite;
      
      public var server_:Server;
      
      public var gameId_:int;
      
      public var createCharacter_:Boolean;
      
      public var charId_:int;
      
      public var keyTime_:int;
      
      public var key_:ByteArray;
      
      public var mapJSON_:String;
      
      public var isFromArena_:Boolean = false;
      
      public var lastTickId_:int = -1;
      
      public var jitterWatcher_:JitterWatcher;
      
      public var serverConnection:SocketServer;
      
      public var outstandingBuy_:Boolean;
      
      public var petId:int;
      
      private var messages:MessageProvider;
      
      private var playerId_:int = -1;
      
      public var player:Player;
      
      private var retryConnection_:Boolean = true;
      
      private var rand_:Random = null;
      
      private var giftChestUpdateSignal:GiftStatusUpdateSignal;
      
      private var alertStatusUpdateSignal:UpdateAlertStatusDisplaySignal;
      
      private var death:Death;
      
      private var retryTimer_:Timer;
      
      private var delayBeforeReconnect:int = 2;
      
      private var addTextLine:AddTextLineSignal;
      
      private var addSpeechBalloon:AddSpeechBalloonSignal;
      
      private var updateGroundTileSignal:UpdateGroundTileSignal;
      
      private var updateGameObjectTileSignal:UpdateGameObjectTileSignal;
      
      private var logger:ILogger;
      
      private var handleDeath:HandleDeathSignal;
      
      private var zombify:ZombifySignal;
      
      private var setGameFocus:SetGameFocusSignal;
      
      private var updateBackpackTab:UpdateBackpackTabSignal;
      
      private var updateMarkTab:UpdateMarkTabSignal;
      
      private var closeDialogs:CloseDialogsSignal;
      
      private var openDialog:OpenDialogSignal;
      
      private var arenaDeath:ArenaDeathSignal;
      
      private var imminentWave:ImminentArenaWaveSignal;
      
      private var questFetchComplete:QuestFetchCompleteSignal;
      
      private var questRedeemComplete:QuestRedeemCompleteSignal;
      
      private var keyInfoResponse:KeyInfoResponseSignal;
      
      private var currentArenaRun:CurrentArenaRunModel;
      
      private var classesModel:ClassesModel;
      
      private var injector:Injector;
      
      private var model:GameModel;
      
      public var battlePassModel:BattlePassModel;
      
      private var lastUseTimeInvUse:int;
      
      private var lastUseTime:int;
      
      public function GameServerConnectionConcrete(param1:GameSprite, param2:Server, param3:int, param4:Boolean, param5:int, param6:int, param7:ByteArray, param8:String, param9:Boolean)
      {
         super();
         this.injector = StaticInjectorContext.getInjector();
         this.giftChestUpdateSignal = this.injector.getInstance(GiftStatusUpdateSignal);
         this.alertStatusUpdateSignal = this.injector.getInstance(UpdateAlertStatusDisplaySignal);
         this.addTextLine = this.injector.getInstance(AddTextLineSignal);
         this.addSpeechBalloon = this.injector.getInstance(AddSpeechBalloonSignal);
         this.updateGroundTileSignal = this.injector.getInstance(UpdateGroundTileSignal);
         this.updateGameObjectTileSignal = this.injector.getInstance(UpdateGameObjectTileSignal);
         this.updateBackpackTab = StaticInjectorContext.getInjector().getInstance(UpdateBackpackTabSignal);
         this.updateMarkTab = StaticInjectorContext.getInjector().getInstance(UpdateMarkTabSignal);
         this.closeDialogs = this.injector.getInstance(CloseDialogsSignal);
         changeMapSignal = this.injector.getInstance(ChangeMapSignal);
         this.openDialog = this.injector.getInstance(OpenDialogSignal);
         this.arenaDeath = this.injector.getInstance(ArenaDeathSignal);
         this.imminentWave = this.injector.getInstance(ImminentArenaWaveSignal);
         this.questFetchComplete = this.injector.getInstance(QuestFetchCompleteSignal);
         this.questRedeemComplete = this.injector.getInstance(QuestRedeemCompleteSignal);
         this.keyInfoResponse = this.injector.getInstance(KeyInfoResponseSignal);
         this.logger = this.injector.getInstance(ILogger);
         this.handleDeath = this.injector.getInstance(HandleDeathSignal);
         this.zombify = this.injector.getInstance(ZombifySignal);
         this.setGameFocus = this.injector.getInstance(SetGameFocusSignal);
         this.classesModel = this.injector.getInstance(ClassesModel);
         serverConnection = this.injector.getInstance(SocketServer);
         this.messages = this.injector.getInstance(MessageProvider);
         this.model = this.injector.getInstance(GameModel);
         this.currentArenaRun = this.injector.getInstance(CurrentArenaRunModel);
         this.battlePassModel = new BattlePassModel();
         condEffTimers = new Dictionary();
         gs = param1;
         server_ = param2;
         gameId_ = param3;
         createCharacter_ = param4;
         charId_ = param5;
         keyTime_ = param6;
         key_ = param7;
         mapJSON_ = param8;
         isFromArena_ = param9;
         instance = this;
      }
      
      private static function onCondEffTime(param1:ConditionEffectTime) : void
      {
         if(condEffTimers[param1.condId] != null && param1.timeCond == 0)
         {
            condEffTimers[param1.condId] = null;
            delete condEffTimers[param1.condId];
         }
         else
         {
            condEffTimers[param1.condId] = param1.timeCond;
         }
      }
      
      private static function setOptions() : int
      {
         var _loc1_:* = 0;
         _loc1_ |= Parameters.data.disableImmuneText << 0;
         return _loc1_ | Parameters.data.disableAllyParticles << 1;
      }
      
      public function disconnect() : void
      {
         this.removeServerConnectionListeners();
         this.unmapMessages();
         serverConnection.disconnect();
      }
      
      private function removeServerConnectionListeners() : void
      {
         serverConnection.connected.remove(this.onConnected);
         serverConnection.closed.remove(this.onClosed);
         serverConnection.error.remove(this.onError);
      }
      
      public function connect() : void
      {
         this.addServerConnectionListeners();
         this.mapMessages();
         var _loc2_:ChatMessage = new ChatMessage();
         _loc2_.name = "*Client*";
         _loc2_.text = "chat.connectingTo";
         var _loc1_:String = server_.name;
         if(_loc1_ == "{\"text\":\"server.vault\"}")
         {
            _loc1_ = "server.vault";
         }
         _loc1_ = LineBuilder.getLocalizedStringFromKey(_loc1_);
         _loc2_.tokens = {"serverName":_loc1_};
         this.addTextLine.dispatch(_loc2_);
         serverConnection.connect(server_.address,server_.port);
      }
      
      public function addServerConnectionListeners() : void
      {
         serverConnection.connected.add(this.onConnected);
         serverConnection.closed.add(this.onClosed);
         serverConnection.error.add(this.onError);
      }
      
      public function mapMessages() : void
      {
         var _loc1_:MessageMap = this.injector.getInstance(MessageMap);
         _loc1_.map(12).toMessage(Create);
         _loc1_.map(66).toMessage(PlayerShoot);
         _loc1_.map(16).toMessage(Move);
         _loc1_.map(47).toMessage(PlayerText);
         _loc1_.map(91).toMessage(Message);
         _loc1_.map(25).toMessage(InvSwap);
         _loc1_.map(1).toMessage(UseItem);
         _loc1_.map(9).toMessage(Hello);
         _loc1_.map(18).toMessage(InvDrop);
         _loc1_.map(64).toMessage(Pong);
         _loc1_.map(26).toMessage(Load);
         _loc1_.map(60).toMessage(SetCondition);
         _loc1_.map(45).toMessage(Teleport);
         _loc1_.map(6).toMessage(UsePortal);
         _loc1_.map(93).toMessage(Buy);
         _loc1_.map(10).toMessage(PlayerHit);
         _loc1_.map(19).toMessage(EnemyHit);
         _loc1_.map(77).toMessage(AoeAck);
         _loc1_.map(35).toMessage(ShootAck);
         _loc1_.map(57).toMessage(OtherHit);
         _loc1_.map(13).toMessage(SquareHit);
         _loc1_.map(79).toMessage(GotoAck);
         _loc1_.map(98).toMessage(GroundDamage);
         _loc1_.map(178).toMessage(GroundTeleporter);
         _loc1_.map(23).toMessage(ChooseName);
         _loc1_.map(95).toMessage(CreateGuild);
         _loc1_.map(49).toMessage(GuildRemove);
         _loc1_.map(41).toMessage(GuildInvite);
         _loc1_.map(34).toMessage(RequestTrade);
         _loc1_.map(168).toMessage(RequestPartyInvite);
         _loc1_.map(55).toMessage(ChangeTrade);
         _loc1_.map(3).toMessage(AcceptTrade);
         _loc1_.map(39).toMessage(CancelTrade);
         _loc1_.map(20).toMessage(CheckCredits);
         _loc1_.map(87).toMessage(Escape);
         _loc1_.map(155).toMessage(GoToQuestRoom);
         _loc1_.map(27).toMessage(JoinGuild);
         _loc1_.map(11).toMessage(ChangeGuildRank);
         _loc1_.map(62).toMessage(EditAccountList);
         _loc1_.map(48).toMessage(EnterArena);
         _loc1_.map(84).toMessage(OutgoingMessage);
         _loc1_.map(51).toMessage(OutgoingMessage);
         _loc1_.map(37).toMessage(QuestRedeem);
         _loc1_.map(151).toMessage(KeyInfoRequest);
         _loc1_.map(156).toMessage(LaunchRaid);
         _loc1_.map(159).toMessage(SorForgeRequest);
         _loc1_.map(160).toMessage(ForgeItem);
         _loc1_.map(163).toMessage(AlertNotice);
         _loc1_.map(165).toMessage(QoLAction);
         _loc1_.map(164).toMessage(MarkRequest);
         _loc1_.map(161).toMessage(UnboxRequest);
         _loc1_.map(99).toMessage(MarketCommand);
         _loc1_.map(167).toMessage(RequestGamble);
         _loc1_.map(170).toMessage(AcceptPartyInvite);
         _loc1_.map(0).toMessage(Failure).toMethod(this.onFailure);
         _loc1_.map(81).toMessage(CreateSuccess).toMethod(this.onCreateSuccess);
         _loc1_.map(92).toMessage(ServerPlayerShoot).toMethod(this.onServerPlayerShoot);
         _loc1_.map(97).toMessage(Damage).toMethod(this.onDamage);
         _loc1_.map(42).toMessage(Update).toMethod(this.onUpdate);
         _loc1_.map(33).toMessage(Notification).toMethod(this.onNotification);
         _loc1_.map(24).toMessage(GlobalNotification).toMethod(this.onGlobalNotification);
         _loc1_.map(68).toMessage(NewTick).toMethod(this.onNewTick);
         _loc1_.map(38).toMessage(ShowEffect).toMethod(this.onShowEffect);
         _loc1_.map(30).toMessage(Goto).toMethod(this.onGoto);
         _loc1_.map(63).toMessage(InvResult).toMethod(this.onInvResult);
         _loc1_.map(14).toMessage(Reconnect).toMethod(this.onReconnect);
         _loc1_.map(85).toMessage(Ping).toMethod(this.onPing);
         _loc1_.map(74).toMessage(MapInfo).toMethod(this.onMapInfo);
         _loc1_.map(46).toMessage(Pic).toMethod(this.onPic);
         _loc1_.map(83).toMessage(Death).toMethod(this.onDeath);
         _loc1_.map(50).toMessage(BuyResult).toMethod(this.onBuyResult);
         _loc1_.map(89).toMessage(Aoe).toMethod(this.onAoe);
         _loc1_.map(44).toMessage(AccountList).toMethod(this.onAccountList);
         _loc1_.map(28).toMessage(QuestObjId).toMethod(this.onQuestObjId);
         _loc1_.map(22).toMessage(NameResult).toMethod(this.onNameResult);
         _loc1_.map(82).toMessage(GuildResult).toMethod(this.onGuildResult);
         _loc1_.map(36).toMessage(AllyShoot).toMethod(this.onAllyShoot);
         _loc1_.map(52).toMessage(EnemyShoot).toMethod(this.onEnemyShoot);
         _loc1_.map(80).toMessage(TradeRequested).toMethod(this.onTradeRequested);
         _loc1_.map(166).toMessage(GambleStart).toMethod(this.onGambleRequest);
         _loc1_.map(169).toMessage(PartyRequest).toMethod(this.onPartyInviteRequest);
         _loc1_.map(31).toMessage(TradeStart).toMethod(this.onTradeStart);
         _loc1_.map(4).toMessage(TradeChanged).toMethod(this.onTradeChanged);
         _loc1_.map(94).toMessage(TradeDone).toMethod(this.onTradeDone);
         _loc1_.map(78).toMessage(TradeAccepted).toMethod(this.onTradeAccepted);
         _loc1_.map(75).toMessage(ClientStat).toMethod(this.onClientStat);
         _loc1_.map(56).toMessage(File).toMethod(this.onFile);
         _loc1_.map(58).toMessage(InvitedToGuild).toMethod(this.onInvitedToGuild);
         _loc1_.map(59).toMessage(PlaySound).toMethod(this.onPlaySound);
         _loc1_.map(5).toMessage(ImminentArenaWave).toMethod(this.onImminentArenaWave);
         _loc1_.map(17).toMessage(ArenaDeath).toMethod(this.onArenaDeath);
         _loc1_.map(61).toMessage(VerifyEmail).toMethod(this.onVerifyEmail);
         _loc1_.map(40).toMessage(ReskinUnlock).toMethod(this.onReskinUnlock);
         _loc1_.map(69).toMessage(PasswordPrompt).toMethod(this.onPasswordPrompt);
         _loc1_.map(65).toMessage(QuestFetchResponse).toMethod(this.onQuestFetchResponse);
         _loc1_.map(88).toMessage(QuestRedeemResponse).toMethod(this.onQuestRedeemResponse);
         _loc1_.map(152).toMessage(KeyInfoResponse).toMethod(this.onKeyInfoResponse);
         _loc1_.map(108).toMessage(SetFocus).toMethod(this.setFocus);
         _loc1_.map(112).toMessage(QueuePong);
         _loc1_.map(110).toMessage(ServerFull).toMethod(this.HandleServerFull);
         _loc1_.map(111).toMessage(QueuePing).toMethod(this.HandleQueuePing);
         _loc1_.map(106).toMessage(SwitchMusic).toMethod(this.onSwitchMusic);
         _loc1_.map(158).toMessage(SorForge).toMethod(this.onSorForge);
         _loc1_.map(162).toMessage(UnboxResultPacket).toMethod(this.unboxResult);
         _loc1_.map(100).toMessage(MarketResult).toMethod(this.HandleMarketResult);
         _loc1_.map(171).toMessage(kabam.rotmg.messaging.impl.incoming.LootNotification).toMethod(this.lootNotif);
         _loc1_.map(172).toMessage(ShowTrials).toMethod(this.onTrialsOpen);
         _loc1_.map(173).toMessage(TrialsRequest);
         _loc1_.map(174).toMessage(PotionStorageInteraction);
         _loc1_.map(175).toMessage(RenameItem);
         _loc1_.map(176).toMessage(HomeDepotInteraction);
         _loc1_.map(177).toMessage(HomeDepotResult).toMethod(this.onHomeDepotResult);
         _loc1_.map(179).toMessage(ClaimBattlePassItem);
         _loc1_.map(180).toMessage(MissionsReceive).toMethod(onMissionsReceive);
         _loc1_.map(181).toMessage(RespriteItem);
         _loc1_.map(182).toMessage(LockItem);
         _loc1_.map(183).toMessage(SendAspectData).toMethod(this.onSendAspectData);
         _loc1_.map(184).toMessage(RefreshMission);
         _loc1_.map(185).toMessage(ConditionEffectTime).toMethod(onCondEffTime);
      }
      
      private function onMissionsReceive(param1:MissionsReceive) : void
      {
         var _loc4_:* = null;
         for each(var _loc3_ in param1.missionsDrop)
         {
            if(battlePassModel.missions[_loc3_])
            {
               battlePassModel.missions[_loc3_] = null;
               delete battlePassModel.missions[_loc3_];
            }
         }
         for each(var _loc2_ in param1.missionsUpdate)
         {
            _loc4_ = new Mission(_loc2_);
            battlePassModel.missions[_loc4_.missionId] = _loc4_;
         }
         if(BattlePassModel.waitForMissionsUpdate)
         {
            BattlePassModel.missionsTabNeedsUpdate = true;
         }
      }
      
      private function onHomeDepotResult(param1:HomeDepotResult) : void
      {
      }
      
      private function onSwitchMusic(param1:SwitchMusic) : void
      {
         Music.load(param1.music);
      }
      
      private function onSendAspectData(param1:SendAspectData) : void
      {
         if(player != null)
         {
            player.AnubisStacks = param1 != null ? param1.anubisStacks : 0;
         }
      }
      
      private function HandleServerFull(param1:ServerFull) : void
      {
         this.injector.getInstance(ShowQueueSignal).dispatch();
         this.injector.getInstance(UpdateQueueSignal).dispatch(param1.position_,param1.count_);
      }
      
      private function HandleQueuePing(param1:QueuePing) : void
      {
         this.injector.getInstance(UpdateQueueSignal).dispatch(param1.position_,param1.count_);
         var _loc2_:QueuePong = this.messages.require(112) as QueuePong;
         _loc2_.serial_ = param1.serial_;
         _loc2_.time_ = getTimer();
         serverConnection.sendMessage(_loc2_);
      }
      
      private function unmapMessages() : void
      {
         var _loc1_:MessageMap = this.injector.getInstance(MessageMap);
         _loc1_.unmap(12);
         _loc1_.unmap(66);
         _loc1_.unmap(16);
         _loc1_.unmap(47);
         _loc1_.unmap(91);
         _loc1_.unmap(25);
         _loc1_.unmap(1);
         _loc1_.unmap(9);
         _loc1_.unmap(18);
         _loc1_.unmap(64);
         _loc1_.unmap(26);
         _loc1_.unmap(60);
         _loc1_.unmap(45);
         _loc1_.unmap(6);
         _loc1_.unmap(93);
         _loc1_.unmap(10);
         _loc1_.unmap(19);
         _loc1_.unmap(77);
         _loc1_.unmap(35);
         _loc1_.unmap(57);
         _loc1_.unmap(13);
         _loc1_.unmap(79);
         _loc1_.unmap(98);
         _loc1_.unmap(178);
         _loc1_.unmap(23);
         _loc1_.unmap(95);
         _loc1_.unmap(49);
         _loc1_.unmap(41);
         _loc1_.unmap(34);
         _loc1_.unmap(168);
         _loc1_.unmap(55);
         _loc1_.unmap(3);
         _loc1_.unmap(39);
         _loc1_.unmap(20);
         _loc1_.unmap(87);
         _loc1_.unmap(155);
         _loc1_.unmap(27);
         _loc1_.unmap(11);
         _loc1_.unmap(62);
         _loc1_.unmap(48);
         _loc1_.unmap(84);
         _loc1_.unmap(51);
         _loc1_.unmap(37);
         _loc1_.unmap(151);
         _loc1_.unmap(156);
         _loc1_.unmap(159);
         _loc1_.unmap(160);
         _loc1_.unmap(163);
         _loc1_.unmap(165);
         _loc1_.unmap(164);
         _loc1_.unmap(161);
         _loc1_.unmap(99);
         _loc1_.unmap(167);
         _loc1_.unmap(170);
         _loc1_.unmap(0);
         _loc1_.unmap(81);
         _loc1_.unmap(92);
         _loc1_.unmap(97);
         _loc1_.unmap(42);
         _loc1_.unmap(33);
         _loc1_.unmap(24);
         _loc1_.unmap(68);
         _loc1_.unmap(38);
         _loc1_.unmap(30);
         _loc1_.unmap(63);
         _loc1_.unmap(14);
         _loc1_.unmap(85);
         _loc1_.unmap(74);
         _loc1_.unmap(46);
         _loc1_.unmap(83);
         _loc1_.unmap(50);
         _loc1_.unmap(89);
         _loc1_.unmap(44);
         _loc1_.unmap(28);
         _loc1_.unmap(22);
         _loc1_.unmap(82);
         _loc1_.unmap(36);
         _loc1_.unmap(52);
         _loc1_.unmap(80);
         _loc1_.unmap(166);
         _loc1_.unmap(169);
         _loc1_.unmap(31);
         _loc1_.unmap(4);
         _loc1_.unmap(94);
         _loc1_.unmap(78);
         _loc1_.unmap(75);
         _loc1_.unmap(56);
         _loc1_.unmap(58);
         _loc1_.unmap(59);
         _loc1_.unmap(5);
         _loc1_.unmap(17);
         _loc1_.unmap(61);
         _loc1_.unmap(40);
         _loc1_.unmap(69);
         _loc1_.unmap(65);
         _loc1_.unmap(88);
         _loc1_.unmap(152);
         _loc1_.unmap(108);
         _loc1_.unmap(112);
         _loc1_.unmap(110);
         _loc1_.unmap(111);
         _loc1_.unmap(106);
         _loc1_.unmap(158);
         _loc1_.unmap(162);
         _loc1_.unmap(100);
         _loc1_.unmap(171);
         _loc1_.unmap(172);
         _loc1_.unmap(173);
         _loc1_.unmap(174);
         _loc1_.unmap(176);
         _loc1_.unmap(177);
         _loc1_.unmap(175);
         _loc1_.unmap(179);
         _loc1_.unmap(180);
         _loc1_.unmap(181);
         _loc1_.unmap(182);
         _loc1_.unmap(183);
         _loc1_.unmap(184);
      }
      
      private function encryptConnection() : void
      {
         var _loc2_:* = null;
         var _loc1_:* = null;
         _loc2_ = Crypto.getCipher("rc4",MoreStringUtil.hexStringToByteArray("BA15DE"));
         _loc1_ = Crypto.getCipher("rc4",MoreStringUtil.hexStringToByteArray("612a806cac78114ba5013cb531"));
         serverConnection.setOutgoingCipher(_loc2_);
         serverConnection.setIncomingCipher(_loc1_);
      }
      
      public function PotionInteraction(param1:int, param2:int, param3:SlotObjectData) : void
      {
         var _loc4_:PotionStorageInteraction;
         (_loc4_ = this.messages.require(174) as PotionStorageInteraction).type_ = param1;
         _loc4_.action_ = param2;
         _loc4_.slotObject = param3;
         this.serverConnection.sendMessage(_loc4_);
      }
      
      public function getNextInt(param1:uint, param2:uint) : uint
      {
         return this.rand_.nextIntRange(param1,param2);
      }
      
      public function enableJitterWatcher() : void
      {
         if(jitterWatcher_ == null)
         {
            jitterWatcher_ = new JitterWatcher();
         }
      }
      
      public function disableJitterWatcher() : void
      {
         if(jitterWatcher_ != null)
         {
            jitterWatcher_ = null;
         }
      }
      
      private function create() : void
      {
         var _loc2_:CharacterClass = this.classesModel.getSelected();
         var _loc1_:Create = this.messages.require(12) as Create;
         _loc1_.classType = _loc2_.id;
         _loc1_.skinType = _loc2_.skins.getSelectedSkin().id;
         serverConnection.sendMessage(_loc1_);
      }
      
      private function load() : void
      {
         var _loc1_:Load = this.messages.require(26) as Load;
         _loc1_.charId_ = charId_;
         _loc1_.isFromArena_ = isFromArena_;
         serverConnection.sendMessage(_loc1_);
         if(isFromArena_)
         {
            this.openDialog.dispatch(new BattleSummaryDialog());
         }
      }
      
      private function onSorForge(param1:SorForge) : void
      {
         var _loc2_:* = null;
         if(param1.isForge)
         {
            _loc2_ = StaticInjectorContext.getInjector().getInstance(OpenDialogSignal);
            _loc2_.dispatch(new SorForgeModal());
         }
      }
      
      private function unboxResult(param1:UnboxResultPacket) : void
      {
         this.openDialog.dispatch(new UnboxResultBox(this.gs,param1.items_));
      }
      
      public function playerShoot(param1:int, param2:Projectile) : void
      {
         var _loc3_:PlayerShoot = this.messages.require(66) as PlayerShoot;
         _loc3_.time_ = param1;
         _loc3_.bulletId_ = param2.bulletId;
         _loc3_.containerType_ = param2.containerType;
         _loc3_.startingPos_.x_ = param2.x_;
         _loc3_.startingPos_.y_ = param2.y_;
         _loc3_.angle_ = param2.angle;
         serverConnection.sendMessage(_loc3_);
      }
      
      public function playerHit(param1:int, param2:int) : void
      {
         var _loc3_:PlayerHit = this.messages.require(10) as PlayerHit;
         _loc3_.bulletId_ = param1;
         _loc3_.objectId_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      public function enemyHit(param1:int, param2:int, param3:int, param4:Boolean) : void
      {
         var _loc5_:EnemyHit;
         (_loc5_ = this.messages.require(19) as EnemyHit).time_ = param1;
         _loc5_.bulletId_ = param2;
         _loc5_.targetId_ = param3;
         _loc5_.kill_ = param4;
         serverConnection.sendMessage(_loc5_);
      }
      
      public function otherHit(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:OtherHit;
         (_loc5_ = this.messages.require(57) as OtherHit).time_ = param1;
         _loc5_.bulletId_ = param2;
         _loc5_.objectId_ = param3;
         _loc5_.targetId_ = param4;
         serverConnection.sendMessage(_loc5_);
      }
      
      public function squareHit(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:SquareHit;
         (_loc4_ = this.messages.require(13) as SquareHit).time_ = param1;
         _loc4_.bulletId_ = param2;
         _loc4_.objectId_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      public function aoeAck(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:AoeAck;
         (_loc4_ = this.messages.require(77) as AoeAck).time_ = param1;
         _loc4_.position_.x_ = param2;
         _loc4_.position_.y_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      public function groundDamage(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:GroundDamage;
         (_loc4_ = this.messages.require(98) as GroundDamage).time_ = param1;
         _loc4_.position_.x_ = param2;
         _loc4_.position_.y_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      public function groundTeleport(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:GroundTeleporter;
         (_loc4_ = this.messages.require(178) as GroundTeleporter).time_ = param1;
         _loc4_.position_.x_ = param2;
         _loc4_.position_.y_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      public function shootAck(param1:int) : void
      {
         var _loc2_:ShootAck = this.messages.require(35) as ShootAck;
         _loc2_.time_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function playerText(param1:String) : void
      {
         var _loc2_:PlayerText = this.messages.require(47) as PlayerText;
         _loc2_.text_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function invSwap(param1:Player, param2:GameObject, param3:int, param4:ItemData, param5:GameObject, param6:int, param7:ItemData) : Boolean
      {
         if(!gs)
         {
            return false;
         }
         var _loc9_:InvSwap;
         (_loc9_ = this.messages.require(25) as InvSwap).time_ = gs.lastUpdate_;
         _loc9_.position_.x_ = param1.x_;
         _loc9_.position_.y_ = param1.y_;
         _loc9_.slotObject1_.objectId_ = param2.objectId;
         _loc9_.slotObject1_.slotId_ = param3;
         _loc9_.slotObject1_.itemData_ = param4.toString();
         _loc9_.slotObject2_.objectId_ = param5.objectId;
         _loc9_.slotObject2_.slotId_ = param6;
         _loc9_.slotObject2_.itemData_ = param7.toString();
         serverConnection.sendMessage(_loc9_);
         var _loc8_:ItemData = param2.equipment_[param3];
         param2.equipment_[param3] = param5.equipment_[param6];
         param5.equipment_[param6] = _loc8_;
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      public function invSwapPotion(param1:Player, param2:GameObject, param3:int, param4:ItemData, param5:GameObject, param6:int, param7:ItemData) : Boolean
      {
         if(!gs)
         {
            return false;
         }
         var _loc8_:InvSwap;
         (_loc8_ = this.messages.require(25) as InvSwap).time_ = gs.lastUpdate_;
         _loc8_.position_.x_ = param1.x_;
         _loc8_.position_.y_ = param1.y_;
         _loc8_.slotObject1_.objectId_ = param2.objectId;
         _loc8_.slotObject1_.slotId_ = param3;
         _loc8_.slotObject1_.itemData_ = param4.toString();
         _loc8_.slotObject2_.objectId_ = param5.objectId;
         _loc8_.slotObject2_.slotId_ = param6;
         _loc8_.slotObject2_.itemData_ = param7.toString();
         param2.equipment_[param3] = new ItemData();
         if(param4.objectType == 2594)
         {
            param1.healthPotionCount_++;
         }
         else if(param4.objectType == 2595)
         {
            param1.magicPotionCount_++;
         }
         serverConnection.sendMessage(_loc8_);
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      public function invDrop(param1:GameObject, param2:int, param3:ItemData) : void
      {
         var _loc4_:InvDrop;
         (_loc4_ = this.messages.require(18) as InvDrop).slotObject_.objectId_ = param1.objectId;
         _loc4_.slotObject_.slotId_ = param2;
         _loc4_.slotObject_.itemData_ = param3.toString();
         serverConnection.sendMessage(_loc4_);
         if(param2 != 254 && param2 != 255)
         {
            param1.equipment_[param2] = new ItemData();
         }
      }
      
      public function useItem(param1:int, param2:int, param3:int, param4:ItemData, param5:Number, param6:Number, param7:int) : void
      {
         var _loc8_:UseItem;
         (_loc8_ = this.messages.require(1) as UseItem).time_ = param1;
         _loc8_.slotObject_.objectId_ = param2;
         _loc8_.slotObject_.slotId_ = param3;
         _loc8_.slotObject_.itemData_ = param4.toString();
         _loc8_.itemUsePos_.x_ = param5;
         _loc8_.itemUsePos_.y_ = param6;
         _loc8_.useType_ = param7;
         serverConnection.sendMessage(_loc8_);
      }
      
      public function useItem_new(param1:GameObject, param2:int) : Boolean
      {
         var _loc11_:* = null;
         var _loc5_:* = undefined;
         var _loc7_:int = 0;
         var _loc9_:* = null;
         var _loc10_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:* = null;
         var _loc4_:ItemData = param1.equipment_[param2];
         var _loc6_:XML;
         if((_loc6_ = ObjectLibrary.xmlLibrary_[_loc4_.objectType]) && !param1.isPaused())
         {
            if(_loc6_.hasOwnProperty("InvUse"))
            {
               if(getTimer() <= this.lastUseTimeInvUse)
               {
                  this.addTextLine.dispatch(ChatMessage.make("","Please wait \'" + ((this.lastUseTimeInvUse - getTimer()) / 1000).toFixed(0) + "\' more seconds before attempting to use this item."));
                  SoundEffectLibrary.play("error");
                  return false;
               }
               this.lastUseTimeInvUse = getTimer() + (!!_loc6_.hasOwnProperty("Cooldown") ? _loc6_.Cooldown * 1000 : Number(550));
            }
            else
            {
               if(getTimer() <= this.lastUseTime)
               {
                  SoundEffectLibrary.play("error");
                  return false;
               }
               this.lastUseTime = getTimer() + (!!_loc6_.hasOwnProperty("Cooldown") ? _loc6_.Cooldown * 1000 : Number(550));
            }
            if(_loc6_.Activate == "IncrementStat" || _loc6_.Activate == "PowerStat")
            {
               _loc11_ = param1 is Player ? param1 as Player : this.player;
               if((_loc5_ = StatData.statToPlayerValues(_loc6_.Activate.@stat,_loc11_)) == null)
               {
                  SoundEffectLibrary.play("error");
                  return false;
               }
               _loc7_ = _loc5_[0] - _loc5_[1];
               if(_loc6_.Activate == "PowerStat")
               {
                  if(!_loc11_.ascended)
                  {
                     this.addTextLine.dispatch(ChatMessage.make("","You must have ascension enabled in order to consume vials."));
                     SoundEffectLibrary.play("error");
                     return false;
                  }
                  _loc10_ = _loc6_.Activate.@stat == 0 || _loc6_.Activate.@stat == 3 ? 50 : 10;
                  if(_loc7_ == _loc5_[2] + _loc10_)
                  {
                     this.addTextLine.dispatch(ChatMessage.make("","\'" + _loc6_.attribute("id") + "\' not consumed." + " You already fully ascended this stat."));
                     SoundEffectLibrary.play("error");
                     return false;
                  }
                  if(_loc7_ + int(_loc6_.Activate.@amount) == _loc5_[2] + _loc10_)
                  {
                     _loc9_ = "You are now fully ascended in this stat.";
                  }
                  else
                  {
                     _loc9_ = _loc5_[2] + _loc10_ - (_loc7_ + int(_loc6_.Activate.@amount)) + " left to fully ascend this stat.";
                  }
                  this.addTextLine.dispatch(ChatMessage.make("","\'" + _loc6_.attribute("id") + "\' consumed. " + _loc9_));
               }
               if(_loc6_.Activate == "IncrementStat")
               {
                  if(_loc7_ >= _loc5_[2])
                  {
                     _loc3_ = _loc6_.Activate.@stat;
                     (_loc8_ = new SlotObjectData()).objectId_ = param1.objectId;
                     _loc8_.slotId_ = param2;
                     _loc8_.itemData_ = _loc4_.toString();
                     switch(_loc3_)
                     {
                        case 0:
                           PotionInteraction(0,0,_loc8_);
                           break;
                        case 3:
                           PotionInteraction(1,0,_loc8_);
                           break;
                        case 20:
                           PotionInteraction(2,0,_loc8_);
                           break;
                        case 21:
                           PotionInteraction(3,0,_loc8_);
                           break;
                        case 22:
                           PotionInteraction(4,0,_loc8_);
                           break;
                        case 26:
                           PotionInteraction(6,0,_loc8_);
                           break;
                        case 27:
                           PotionInteraction(7,0,_loc8_);
                           break;
                        case 28:
                           PotionInteraction(5,0,_loc8_);
                           break;
                        case 121:
                           PotionInteraction(10,0,_loc8_);
                           break;
                        case 122:
                           PotionInteraction(11,0,_loc8_);
                           break;
                        case 112:
                           PotionInteraction(8,0,_loc8_);
                           break;
                        case 114:
                           PotionInteraction(9,0,_loc8_);
                     }
                     this.addTextLine.dispatch(ChatMessage.make("","\'" + _loc6_.attribute("id") + "\' not consumed. " + "You already maxed this stat."));
                     return false;
                  }
                  if(_loc7_ + int(_loc6_.Activate.@amount) >= _loc5_[2])
                  {
                     _loc9_ = "You are now maxed in this stat.";
                  }
                  else
                  {
                     _loc9_ = _loc5_[2] - (_loc7_ + int(_loc6_.Activate.@amount)) + " left to max this stat.";
                  }
                  this.addTextLine.dispatch(ChatMessage.make("","\'" + _loc6_.attribute("id") + "\' consumed. " + _loc9_));
               }
               this.applyUseItem(param1,param2,_loc4_,_loc6_);
               SoundEffectLibrary.play("use_potion");
               return true;
            }
            if(_loc6_.hasOwnProperty("Consumable") || _loc6_.hasOwnProperty("InvUse"))
            {
               this.applyUseItem(param1,param2,_loc4_,_loc6_);
               SoundEffectLibrary.play("use_potion");
               return true;
            }
         }
         SoundEffectLibrary.play("error");
         return false;
      }
      
      private function applyUseItem(param1:GameObject, param2:int, param3:ItemData, param4:XML) : void
      {
         var _loc5_:UseItem;
         (_loc5_ = this.messages.require(1) as UseItem).time_ = getTimer();
         _loc5_.slotObject_.objectId_ = param1.objectId;
         _loc5_.slotObject_.slotId_ = param2;
         _loc5_.slotObject_.itemData_ = param3.toString();
         _loc5_.itemUsePos_.x_ = 0;
         _loc5_.itemUsePos_.y_ = 0;
         serverConnection.sendMessage(_loc5_);
         if(param4.hasOwnProperty("Consumable"))
         {
            param1.equipment_[param2] = new ItemData();
         }
      }
      
      public function setCondition(param1:uint, param2:Number) : void
      {
         var _loc3_:SetCondition = this.messages.require(60) as SetCondition;
         _loc3_.conditionEffect_ = param1;
         _loc3_.conditionDuration_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      public function move(param1:int, param2:Player) : void
      {
         var _loc3_:* = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:* = -1;
         var _loc4_:* = -1;
         if(param2 && !param2.isPaused())
         {
            _loc5_ = Number(param2.x_);
            _loc4_ = Number(param2.y_);
         }
         if(param1 >= 0)
         {
            _loc3_ = this.messages.require(16) as Move;
            _loc3_.objectId_ = param2.objectId;
            _loc3_.tickId_ = param1;
            _loc3_.time_ = gs.lastUpdate_;
            _loc3_.options = setOptions();
            _loc3_.newPosition_.x_ = _loc5_;
            _loc3_.newPosition_.y_ = _loc4_;
            _loc8_ = gs.moveRecords_.lastClearTime_;
            _loc3_.records_.length = 0;
            if(_loc8_ >= 0 && _loc3_.time_ - _loc8_ > 125)
            {
               _loc7_ = Math.min(10,gs.moveRecords_.records_.length);
               _loc6_ = 0;
               while(_loc6_ < _loc7_)
               {
                  if(gs.moveRecords_.records_[_loc6_].time_ >= _loc3_.time_ - 25)
                  {
                     break;
                  }
                  _loc3_.records_.push(gs.moveRecords_.records_[_loc6_]);
                  _loc6_++;
               }
            }
            gs.moveRecords_.clear(_loc3_.time_);
            serverConnection.sendMessage(_loc3_);
         }
         param2 && param2.onMove();
      }
      
      public function teleport(param1:int) : void
      {
         var _loc2_:Teleport = this.messages.require(45) as Teleport;
         _loc2_.objectId_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function usePortal(param1:int) : void
      {
         var _loc2_:UsePortal = this.messages.require(6) as UsePortal;
         _loc2_.objectId_ = param1;
         serverConnection.sendMessage(_loc2_);
         this.checkDavyKeyRemoval();
      }
      
      private function checkDavyKeyRemoval() : void
      {
         if(gs.map && gs.map.mapName == "Davy Jones\' Locker")
         {
            ShowHideKeyUISignal.instance.dispatch();
         }
      }
      
      private function onTrialsOpen(param1:ShowTrials) : void
      {
         var _loc2_:* = null;
         if(param1.openDialog)
         {
            _loc2_ = StaticInjectorContext.getInjector().getInstance(OpenDialogSignal);
            _loc2_.dispatch(new TrialsPanel(gs));
         }
      }
      
      public function buy(param1:int, param2:int) : void
      {
         var sellableObjectId:int = param1;
         var quantity:int = param2;
         if(outstandingBuy_)
         {
            return;
         }
         var sObj:SellableObject = gs.map.goDict[sellableObjectId];
         if(sObj == null)
         {
            return;
         }
         if(sObj.soldObjectName() == "Vault.chest")
         {
            this.openDialog.dispatch(new PurchaseConfirmationDialog(function():void
            {
               buyConfirmation(sellableObjectId,quantity);
            }));
         }
         else
         {
            this.buyConfirmation(sellableObjectId,quantity);
         }
      }
      
      public function buyConfirmation(param1:int, param2:int, param3:uint = 0, param4:int = 0) : void
      {
         outstandingBuy_ = true;
         var _loc5_:Buy;
         (_loc5_ = this.messages.require(93) as Buy).objectId_ = param1;
         _loc5_.quantity_ = param2;
         _loc5_.marketId_ = param3;
         _loc5_.type_ = param4;
         serverConnection.sendMessage(_loc5_);
      }
      
      public function marketGUIBuy(param1:int, param2:int) : void
      {
      }
      
      public function gotoAck(param1:int) : void
      {
         var _loc2_:GotoAck = this.messages.require(79) as GotoAck;
         _loc2_.time_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function editAccountList(param1:int, param2:Boolean, param3:int) : void
      {
         var _loc4_:EditAccountList;
         (_loc4_ = this.messages.require(62) as EditAccountList).accountListId_ = param1;
         _loc4_.add_ = param2;
         _loc4_.objectId_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      public function chooseName(param1:String) : void
      {
         var _loc2_:ChooseName = this.messages.require(23) as ChooseName;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function createGuild(param1:String) : void
      {
         var _loc2_:CreateGuild = this.messages.require(95) as CreateGuild;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function guildRemove(param1:String) : void
      {
         var _loc2_:GuildRemove = this.messages.require(49) as GuildRemove;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function guildInvite(param1:String) : void
      {
         var _loc2_:GuildInvite = this.messages.require(41) as GuildInvite;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function requestTrade(param1:String) : void
      {
         var _loc2_:RequestTrade = this.messages.require(34) as RequestTrade;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function requestPartyInvite(param1:String) : void
      {
         var _loc2_:RequestPartyInvite = this.messages.require(168) as RequestPartyInvite;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function requestGamble(param1:String, param2:int) : void
      {
         var _loc3_:RequestGamble = this.messages.require(167) as RequestGamble;
         _loc3_.name_ = param1;
         _loc3_.amount_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      public function acceptPartyInvite(param1:String) : void
      {
         var _loc2_:AcceptPartyInvite = this.messages.require(170) as AcceptPartyInvite;
         _loc2_.From_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function changeTrade(param1:Vector.<Boolean>) : void
      {
         var _loc2_:ChangeTrade = this.messages.require(55) as ChangeTrade;
         _loc2_.offer_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function acceptTrade(param1:Vector.<Boolean>, param2:Vector.<Boolean>) : void
      {
         var _loc3_:AcceptTrade = this.messages.require(3) as AcceptTrade;
         _loc3_.myOffer_ = param1;
         _loc3_.yourOffer_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      public function cancelTrade() : void
      {
         serverConnection.sendMessage(this.messages.require(39));
      }
      
      public function checkCredits() : void
      {
         serverConnection.sendMessage(this.messages.require(20));
      }
      
      public function escape() : void
      {
         if(this.playerId_ == -1)
         {
            return;
         }
         if(gameId_ == -2)
         {
            gs.closed.dispatch();
            return;
         }
         if(gs.map && gs.map.mapName == "Arena")
         {
            serverConnection.sendMessage(this.messages.require(84));
            return;
         }
         this.checkDavyKeyRemoval();
         reconnect2Nexus();
      }
      
      public function gotoQuestRoom() : void
      {
         serverConnection.sendMessage(this.messages.require(155));
      }
      
      public function joinGuild(param1:String) : void
      {
         var _loc2_:JoinGuild = this.messages.require(27) as JoinGuild;
         _loc2_.guildName_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function changeGuildRank(param1:String, param2:int) : void
      {
         var _loc3_:ChangeGuildRank = this.messages.require(11) as ChangeGuildRank;
         _loc3_.name_ = param1;
         _loc3_.guildRank_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      private function rsaEncrypt(param1:String) : String
      {
         var _loc2_:RSAKey = PEM.readRSAPublicKey("-----BEGIN PUBLIC KEY-----\nMFswDQYJKoZIhvcNAQEBBQADSgAwRwJAeyjMOLhcK4o2AnFRhn8vPteUy5Fux/cXN/J+wT/zYIEUINo02frn+Kyxx0RIXJ3CvaHkwmueVL8ytfqo8Ol/OwIDAQAB\n-----END PUBLIC KEY-----");
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(param1);
         var _loc4_:ByteArray = new ByteArray();
         _loc2_.encrypt(_loc3_,_loc4_,_loc3_.length);
         return Base64.encodeByteArray(_loc4_);
      }
      
      private function onConnected() : void
      {
         var _loc1_:Account = StaticInjectorContext.getInjector().getInstance(Account);
         this.addTextLine.dispatch(ChatMessage.make("*Client*","chat.connected"));
         this.encryptConnection();
         var _loc2_:Hello = this.messages.require(9) as Hello;
         _loc2_.buildVersion = "4.4.0";
         _loc2_.gameId = gameId_;
         _loc2_.guid = this.rsaEncrypt(_loc1_.getUserId());
         _loc2_.loginToken = this.rsaEncrypt(_loc1_.getLoginToken());
         _loc2_.keyTime = keyTime_;
         _loc2_.key.length = 0;
         key_ != null && _loc2_.key.writeBytes(key_);
         _loc2_.mapJSON = mapJSON_ == null ? "" : mapJSON_;
         serverConnection.sendMessage(_loc2_);
      }
      
      private function onCreateSuccess(param1:CreateSuccess) : void
      {
         this.playerId_ = param1.objectId_;
         charId_ = param1.charId_;
         gs.initialize();
         createCharacter_ = false;
      }
      
      private function onDamage(param1:Damage) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc2_:AbstractMap = gs.map;
         if(param1.objectId_ >= 0 && param1.bulletId_ > 0)
         {
            if((_loc5_ = Projectile.findObjId(param1.objectId_,param1.bulletId_)) != -1)
            {
               _loc3_ = _loc2_.boDict[_loc5_] as Projectile;
               if(_loc3_ != null && !_loc3_.projProps.multiHit)
               {
                  _loc2_.removeObj(_loc5_);
               }
            }
         }
         var _loc4_:GameObject;
         if((_loc4_ = _loc2_.goDict[param1.targetId_]) != null && !_loc4_.dead && !(_loc4_ is Player && _loc4_.objectId != this.playerId_ && Parameters.data.noAllyDamage))
         {
            _loc4_.damage(-1,param1.damageAmount_,param1.effects_,param1.kill_,_loc3_);
         }
      }
      
      private function onServerPlayerShoot(param1:ServerPlayerShoot) : void
      {
         var _loc4_:* = null;
         _loc4_ = null;
         var _loc2_:* = param1.ownerId_ == this.playerId_;
         var _loc3_:GameObject = gs.map.goDict[param1.ownerId_];
         if(_loc3_ == null || _loc3_.dead)
         {
            if(_loc2_)
            {
               this.shootAck(-1);
            }
            return;
         }
         if(_loc3_.objectId != this.playerId_ && Parameters.data.disableAllyParticles)
         {
            return;
         }
         var _loc5_:Projectile = FreeList.newObject(Projectile) as Projectile;
         var _loc6_:Player = _loc3_ as Player;
         if(param1.itemData == "NaN")
         {
            _loc4_ = null;
         }
         else
         {
            _loc4_ = new ItemData(param1.itemData);
         }
         if(_loc6_ != null)
         {
            _loc5_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs.lastUpdate_,_loc6_.projectileIdSetOverrideNew,_loc6_.projectileIdSetOverrideOld,_loc4_);
         }
         else
         {
            _loc5_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs.lastUpdate_,"","",_loc4_);
         }
         _loc5_.setDamage(param1.damage_);
         gs.map.addObj(_loc5_,param1.startingPos_.x_,param1.startingPos_.y_);
         if(_loc2_)
         {
            this.shootAck(gs.lastUpdate_);
         }
      }
      
      private function onAllyShoot(param1:AllyShoot) : void
      {
         var _loc2_:GameObject = gs.map.goDict[param1.ownerId_];
         if(_loc2_ == null || _loc2_.dead || Parameters.data.disableAllyParticles)
         {
            return;
         }
         var _loc3_:Projectile = FreeList.newObject(Projectile) as Projectile;
         var _loc4_:Player;
         if((_loc4_ = _loc2_ as Player) != null)
         {
            _loc3_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs.lastUpdate_,_loc4_.projectileIdSetOverrideNew,_loc4_.projectileIdSetOverrideOld);
         }
         else
         {
            _loc3_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs.lastUpdate_);
         }
         gs.map.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
         _loc2_.setAttack(param1.containerType_,param1.angle_);
      }
      
      private function onReskinUnlock(param1:ReskinUnlock) : void
      {
         var _loc2_:* = null;
         _loc2_ = this.classesModel.getCharacterClass(this.model.player.objectType_).skins.getSkin(param1.skinID);
         _loc2_.setState(CharacterSkinState.OWNED);
      }
      
      private function onEnemyShoot(param1:EnemyShoot) : void
      {
         var _loc4_:* = null;
         var _loc5_:Number = NaN;
         var _loc3_:int = 0;
         var _loc2_:GameObject = gs.map.goDict[param1.ownerId_];
         if(_loc2_ == null || _loc2_.dead)
         {
            this.shootAck(-1);
            return;
         }
         while(_loc3_ < param1.numShots_)
         {
            _loc4_ = FreeList.newObject(Projectile) as Projectile;
            _loc5_ = param1.angle_ + param1.angleInc_ * _loc3_;
            _loc4_.reset(_loc2_.objectType_,param1.bulletType_,param1.ownerId_,(param1.bulletId_ + _loc3_) % 512,_loc5_,gs.lastUpdate_);
            _loc4_.setDamage(param1.damage_);
            gs.map.addObj(_loc4_,param1.startingPos_.x_,param1.startingPos_.y_);
            _loc3_++;
         }
         this.shootAck(gs.lastUpdate_);
         _loc2_.setAttack(_loc2_.objectType_,param1.angle_ + param1.angleInc_ * ((param1.numShots_ - 1) / 2));
      }
      
      private function onTradeRequested(param1:TradeRequested) : void
      {
         if(!Parameters.data.chatTrade)
         {
            return;
         }
         if(Parameters.data.tradeWithFriends)
         {
            return;
         }
         if(Parameters.data.showTradePopup)
         {
            gs.hudView.interactPanel.setOverride(new TradeRequestPanel(gs,param1.name_));
         }
         this.addTextLine.dispatch(ChatMessage.make("",param1.name_ + " wants to " + "trade with you.  Type \"/trade " + param1.name_ + "\" to trade."));
      }
      
      private function onGambleRequest(param1:GambleStart) : void
      {
         if(!Parameters.data.chatTrade)
         {
            return;
         }
         if(Parameters.data.tradeWithFriends)
         {
            return;
         }
         if(Parameters.data.showTradePopup)
         {
            gs.hudView.interactPanel.setOverride(new GambleRequestPanel(gs,param1.name_,param1.amount_));
         }
         this.addTextLine.dispatch(ChatMessage.make("",param1.name_ + " wants to " + "gamble with you."));
      }
      
      private function onPartyInviteRequest(param1:PartyRequest) : void
      {
         if(!Parameters.data.chatTrade)
         {
            return;
         }
         if(Parameters.data.tradeWithFriends)
         {
            return;
         }
         if(Parameters.data.showTradePopup)
         {
            gs.hudView.interactPanel.setOverride(new PartyInvitePanel(gs,param1.from_,param1.name_));
         }
      }
      
      private function onTradeStart(param1:TradeStart) : void
      {
         gs.hudView.startTrade(gs,param1);
      }
      
      private function onTradeChanged(param1:TradeChanged) : void
      {
         gs.hudView.tradeChanged(param1);
      }
      
      private function onTradeDone(param1:TradeDone) : void
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         gs.hudView.tradeDone();
         var _loc2_:String = "";
         try
         {
            _loc2_ = (_loc4_ = JSON.parse(param1.description_)).key;
            _loc3_ = _loc4_.tokens;
         }
         catch(e:Error)
         {
         }
         this.addTextLine.dispatch(ChatMessage.make("",_loc2_,-1,-1,"",false,_loc3_));
      }
      
      private function onTradeAccepted(param1:TradeAccepted) : void
      {
         gs.hudView.tradeAccepted(param1);
      }
      
      private function addObject(param1:ObjectData) : void
      {
         var _loc2_:AbstractMap = gs.map;
         var _loc3_:GameObject = ObjectLibrary.getObjectFromType(param1.objectType_);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:ObjectStatusData = param1.status_;
         _loc3_.setObjectId(_loc4_.objectId_);
         _loc2_.addObj(_loc3_,_loc4_.pos_.x_,_loc4_.pos_.y_);
         if(_loc3_ is Player)
         {
            this.handleNewPlayer(_loc3_ as Player,_loc2_);
         }
         this.processObjectStatus(_loc4_,0,-1);
         if(_loc3_.props.static_ && _loc3_.props.occupySquare_ && !_loc3_.props.noMiniMap_)
         {
            this.updateGameObjectTileSignal.dispatch(new UpdateGameObjectTileVO(_loc3_.x_,_loc3_.y_,_loc3_));
         }
      }
      
      private function handleNewPlayer(param1:Player, param2:AbstractMap) : void
      {
         this.setPlayerSkinTemplate(param1,0);
         if(param1.objectId == this.playerId_)
         {
            this.player = param1;
            this.model.player = param1;
            param2.player = param1;
            gs.setFocus(param1);
            this.setGameFocus.dispatch(this.playerId_.toString());
         }
      }
      
      private function onUpdate(param1:Update) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc2_:Message = this.messages.require(91);
         serverConnection.sendMessage(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < param1.tiles.length)
         {
            _loc4_ = param1.tiles[_loc3_];
            gs.map.setGroundTile(_loc4_.x_,_loc4_.y_,_loc4_.type_);
            this.updateGroundTileSignal.dispatch(new UpdateGroundTileVO(_loc4_.x_,_loc4_.y_,_loc4_.type_));
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param1.drops.length)
         {
            gs.map.removeObj(param1.drops[_loc3_]);
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param1.newObjs.length)
         {
            this.addObject(param1.newObjs[_loc3_]);
            _loc3_++;
         }
      }
      
      private function onNotification(param1:Notification) : void
      {
         var _loc2_:LineBuilder = null;
         var _loc3_:GameObject = gs.map.goDict[param1.objectId_];
         if(_loc3_ != null)
         {
            _loc2_ = LineBuilder.fromJSON(param1.message);
            if(_loc3_ == this.player)
            {
               if(_loc2_.key == "server.quest_complete")
               {
                  gs.map.quest.completed();
               }
               this.makeNotification(_loc2_,_loc3_,param1.color_,1000);
            }
            else if(_loc3_.props.isEnemy || !Parameters.data.noAllyNotifications)
            {
               this.makeNotification(_loc2_,_loc3_,param1.color_,1000);
            }
         }
      }
      
      private function makeNotification(param1:LineBuilder, param2:GameObject, param3:uint, param4:int) : void
      {
         var _loc5_:CharacterStatusText;
         (_loc5_ = new CharacterStatusText(param2,param3,param4)).setStringBuilder(param1);
         gs.map.mapOverlay.addStatusText(_loc5_);
      }
      
      private function onGlobalNotification(param1:GlobalNotification) : void
      {
         switch(param1.text)
         {
            case "yellow":
               ShowKeySignal.instance.dispatch(Key.YELLOW);
               return;
            case "red":
               ShowKeySignal.instance.dispatch(Key.RED);
               return;
            case "green":
               ShowKeySignal.instance.dispatch(Key.GREEN);
               return;
            case "purple":
               ShowKeySignal.instance.dispatch(Key.PURPLE);
               return;
            case "showKeyUI":
               ShowHideKeyUISignal.instance.dispatch();
               return;
            case "giftChestOccupied":
               this.giftChestUpdateSignal.dispatch(true);
               return;
            case "giftChestEmpty":
               this.giftChestUpdateSignal.dispatch(false);
               return;
            case "beginnersPackage":
               return;
            default:
               return;
         }
      }
      
      private function onNewTick(param1:NewTick) : void
      {
         var _loc2_:* = null;
         if(jitterWatcher_ != null)
         {
            jitterWatcher_.record();
         }
         this.move(param1.tickId_,this.player);
         for each(_loc2_ in param1.statuses_)
         {
            this.processObjectStatus(_loc2_,param1.tickTime_,param1.tickId_);
         }
         lastTickId_ = param1.tickId_;
      }
      
      private function canShowEffect(param1:GameObject) : Boolean
      {
         if(param1 != null)
         {
            return true;
         }
         var _loc2_:* = param1.objectId == this.playerId_;
         return !_loc2_ && param1.props.isPlayer && Parameters.data.disableAllyParticles;
      }
      
      private function onShowEffect(param1:ShowEffect) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = 0;
         var _loc5_:AbstractMap = gs.map;
         if(Parameters.data.noParticlesMaster && (param1.effectType_ == 1 || param1.effectType_ == 2 || param1.effectType_ == 3 || param1.effectType_ == 6 || param1.effectType_ == 7 || param1.effectType_ == 9 || param1.effectType_ == 12 || param1.effectType_ == 13))
         {
            return;
         }
         switch(int(param1.effectType_) - 1)
         {
            case 0:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc5_.addObj(new HealEffect(_loc3_,param1.color_),_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 3:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc6_ = _loc3_ != null ? new Point(_loc3_.x_,_loc3_.y_) : param1.pos2_.toPoint();
                  _loc2_ = new ThrowEffect(_loc6_,param1.pos1_.toPoint(),param1.color_,param1.duration_ * 1000);
                  _loc5_.addObj(_loc2_,_loc6_.x,_loc6_.y);
                  return;
               }
               break;
            case 4:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new NovaEffect(_loc3_,param1.pos1_.x_,param1.color_);
                  _loc5_.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 5:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new PoisonEffect(_loc3_,param1.color_);
                  _loc5_.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 6:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new LineEffect(_loc3_,param1.pos1_,param1.color_);
                  _loc5_.addObj(_loc2_,param1.pos1_.x_,param1.pos1_.y_);
                  return;
               }
               break;
            case 7:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new BurstEffect(_loc3_,param1.pos1_,param1.pos2_,param1.color_);
                  _loc5_.addObj(_loc2_,param1.pos1_.x_,param1.pos1_.y_);
                  return;
               }
               break;
            case 8:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new FlowEffect(param1.pos1_,_loc3_,param1.color_);
                  _loc5_.addObj(_loc2_,param1.pos1_.x_,param1.pos1_.y_);
                  return;
               }
               break;
            case 9:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new RingEffect(_loc3_,param1.pos1_.x_,param1.color_);
                  _loc5_.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 10:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new LightningEffect(_loc3_,param1.pos1_,param1.color_,param1.pos2_.x_);
                  _loc5_.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 11:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new CollapseEffect(_loc3_,param1.pos1_,param1.pos2_,param1.color_);
                  _loc5_.addObj(_loc2_,param1.pos1_.x_,param1.pos1_.y_);
                  return;
               }
               break;
            case 12:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new ConeBlastEffect(_loc3_,param1.pos1_,param1.pos2_.x_,param1.color_);
                  _loc5_.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 14:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc3_.flash = new FlashDescription(getTimer(),param1.color_,param1.pos1_.x_,param1.pos1_.y_);
                  return;
               }
               break;
            case 15:
               _loc6_ = param1.pos1_.toPoint();
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new ThrowProjectileEffect(param1.color_,param1.pos2_.toPoint(),param1.pos1_.toPoint());
                  _loc5_.addObj(_loc2_,_loc6_.x,_loc6_.y);
                  return;
               }
               break;
            case 16:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  if(_loc3_ && _loc3_.shockEffect)
                  {
                     _loc3_.shockEffect.destroy();
                  }
                  _loc2_ = new ShockerEffect(_loc3_);
                  _loc3_.shockEffect = ShockerEffect(_loc2_);
                  gs.map.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 17:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc2_ = new ShockeeEffect(_loc3_);
                  gs.map.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            case 18:
               _loc3_ = _loc5_.goDict[param1.targetObjectId_];
               if(!(_loc3_ == null || !this.canShowEffect(_loc3_)))
               {
                  _loc4_ = uint(param1.pos1_.x_ * 1000);
                  _loc2_ = new RisingFuryEffect(_loc3_,_loc4_);
                  gs.map.addObj(_loc2_,_loc3_.x_,_loc3_.y_);
                  return;
               }
               break;
            default:
               break;
            case 1:
               _loc5_.addObj(new TeleportEffect(),param1.pos1_.x_,param1.pos1_.y_);
               return;
            case 2:
               _loc2_ = new StreamEffect(param1.pos1_,param1.pos2_,param1.color_);
               _loc5_.addObj(_loc2_,param1.pos1_.x_,param1.pos1_.y_);
               return;
            case 13:
               gs.camera_.startJitter();
               return;
         }
      }
      
      private function onGoto(param1:Goto) : void
      {
         this.gotoAck(gs.lastUpdate_);
         var _loc2_:GameObject = gs.map.goDict[param1.objectId_];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.onGoto(param1.pos_.x_,param1.pos_.y_,gs.lastUpdate_);
      }
      
      private function updateGameObject(param1:GameObject, param2:Vector.<StatData>, param3:Boolean) : void
      {
         var _loc7_:* = null;
         var _loc4_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:* = null;
         var _loc10_:Player = param1 as Player;
         var _loc6_:Merchant = param1 as Merchant;
         for each(_loc7_ in param2)
         {
            _loc4_ = _loc7_.statValue_;
            switch(_loc7_.statType_)
            {
               case 0:
                  param1.maxHP_ = _loc4_;
                  continue;
               case 1:
                  param1.hp_ = _loc4_;
                  continue;
               case 2:
                  param1.setSize(_loc4_);
                  continue;
               case 3:
                  _loc10_.maxMP_ = _loc4_;
                  continue;
               case 4:
                  _loc10_.mp_ = _loc4_;
                  continue;
               case 5:
                  _loc10_.nextLevelExp_ = _loc4_;
                  continue;
               case 6:
                  _loc10_.exp_ = _loc4_;
                  continue;
               case 7:
                  param1.level_ = _loc4_;
                  continue;
               case 20:
                  _loc10_.attack_ = _loc4_;
                  continue;
               case 21:
                  param1.defense_ = _loc4_;
                  continue;
               case 22:
                  _loc10_.speed_ = _loc4_;
                  continue;
               case 28:
                  _loc10_.dexterity_ = _loc4_;
                  continue;
               case 26:
                  _loc10_.vitality_ = _loc4_;
                  continue;
               case 27:
                  _loc10_.wisdom_ = _loc4_;
                  continue;
               case 29:
                  param1.condition_[0] = _loc4_;
                  continue;
               case 8:
               case 9:
               case 10:
               case 11:
               case 12:
               case 13:
               case 14:
               case 15:
               case 16:
               case 17:
               case 18:
                  break;
               case 19:
                  break;
               case 30:
                  _loc10_.numStars_ = _loc4_;
                  continue;
               case 31:
                  if(param1.name_ != _loc7_.strStatValue_)
                  {
                     param1.name_ = _loc7_.strStatValue_;
                     param1.nameBitmapData_ = null;
                  }
                  continue;
               case 32:
                  if(_loc4_ >= 0)
                  {
                     param1.setTex1(_loc4_);
                  }
                  continue;
               case 33:
                  if(_loc4_ >= 0)
                  {
                     param1.setTex2(_loc4_);
                  }
                  continue;
               case 34:
                  _loc6_.setMerchandiseType(new ItemData(_loc7_.strStatValue_));
                  continue;
               case 35:
                  _loc10_.setCredits(_loc4_);
                  continue;
               case 36:
                  (param1 as SellableObject).setPrice(_loc4_);
                  continue;
               case 37:
                  continue;
               case 38:
                  _loc10_.accountId_ = _loc7_.strStatValue_;
                  continue;
               case 39:
                  _loc10_.fame_ = _loc4_;
                  continue;
               case 97:
                  _loc10_.setTokens(_loc4_);
                  continue;
               case 40:
                  (param1 as SellableObject).setCurrency(_loc4_);
                  continue;
               case 41:
                  param1.connectType_ = _loc4_;
                  continue;
               case 42:
                  _loc6_.count_ = _loc4_;
                  _loc6_.untilNextMessage_ = 0;
                  continue;
               case 43:
                  _loc6_.minsLeft_ = _loc4_;
                  _loc6_.untilNextMessage_ = 0;
                  continue;
               case 44:
                  _loc6_.discount_ = _loc4_;
                  _loc6_.untilNextMessage_ = 0;
                  continue;
               case 45:
                  (param1 as SellableObject).setRankReq(_loc4_);
                  continue;
               case 46:
                  _loc10_.maxHPBoost_ = _loc4_;
                  continue;
               case 47:
                  _loc10_.maxMPBoost_ = _loc4_;
                  continue;
               case 48:
                  _loc10_.attackBoost_ = _loc4_;
                  continue;
               case 49:
                  _loc10_.defenseBoost_ = _loc4_;
                  continue;
               case 50:
                  _loc10_.speedBoost_ = _loc4_;
                  continue;
               case 51:
                  _loc10_.vitalityBoost_ = _loc4_;
                  continue;
               case 52:
                  _loc10_.wisdomBoost_ = _loc4_;
                  continue;
               case 53:
                  _loc10_.dexterityBoost_ = _loc4_;
                  continue;
               case 54:
                  if(param1 is Friend)
                  {
                     (param1 as Friend).accOwnerId = _loc7_.strStatValue_;
                     return;
                  }
                  if(param1 is Container)
                  {
                     (param1 as Container).setOwnerId(_loc7_.strStatValue_);
                  }
                  continue;
               case 55:
                  (param1 as NameChanger).setRankRequired(_loc4_);
                  continue;
               case 56:
                  _loc10_.nameChosen_ = _loc4_ != 0;
                  param1.nameBitmapData_ = null;
                  continue;
               case 57:
                  _loc10_.currFame_ = _loc4_;
                  continue;
               case 58:
                  _loc10_.nextClassQuestFame_ = _loc4_;
                  continue;
               case 59:
                  _loc10_.setGlow(_loc4_);
                  continue;
               case 60:
                  if(!param3)
                  {
                     _loc10_.sinkLevel = _loc4_;
                  }
                  continue;
               case 61:
                  param1.setAltTexture(_loc4_);
                  continue;
               case 62:
                  _loc10_.setGuildName(_loc7_.strStatValue_);
                  continue;
               case 63:
                  _loc10_.guildRank_ = _loc4_;
                  continue;
               case 65:
                  _loc10_.xpBoost_ = _loc4_;
                  continue;
               case 66:
                  _loc10_.xpTimer = _loc4_ * 1000;
                  continue;
               case 67:
                  _loc10_.dropBoost = _loc4_ * 1000;
                  continue;
               case 68:
                  _loc10_.tierBoost = _loc4_ * 1000;
                  continue;
               case 69:
                  _loc10_.healthPotionCount_ = _loc4_;
                  continue;
               case 70:
                  _loc10_.magicPotionCount_ = _loc4_;
                  continue;
               case 80:
                  if(_loc10_.skinId != _loc4_ && _loc4_ >= 0)
                  {
                     this.setPlayerSkinTemplate(_loc10_,_loc4_);
                  }
                  continue;
               case 79:
                  (param1 as Player).hasBackpack_ = Boolean(_loc4_);
                  if(param3)
                  {
                     this.updateBackpackTab.dispatch(Boolean(_loc4_));
                  }
                  continue;
               case 71:
               case 72:
               case 73:
               case 74:
               case 75:
               case 76:
               case 77:
               case 78:
                  _loc9_ = _loc7_.statType_ - 71 + 4 + 8;
                  if((param1 as Player).equipment_.length <= _loc9_)
                  {
                     (param1 as Player).equipment_.length = _loc9_ + 1;
                  }
                  (param1 as Player).equipment_[_loc9_] = new ItemData(_loc7_.strStatValue_);
                  continue;
               case 96:
                  param1.condition_[1] = _loc4_;
                  continue;
               case 109:
                  _loc10_.raidRank_ = _loc4_;
                  continue;
               case 103:
                  _loc10_.rank_ = _loc4_;
                  continue;
               case 104:
                  _loc10_.admin_ = _loc4_ == 1;
                  continue;
               case 106:
                  _loc10_.setOnrane(_loc4_);
                  continue;
               case 107:
                  _loc10_.setKantos(_loc4_);
                  continue;
               case 108:
                  _loc10_.alertToken_ = _loc4_;
                  continue;
               case 110:
                  _loc10_.surge_ = _loc4_;
                  continue;
               case 112:
                  _loc10_.might_ = _loc4_;
                  continue;
               case 114:
                  _loc10_.luck_ = _loc4_;
                  continue;
               case 113:
                  _loc10_.mightBoost_ = _loc4_;
                  continue;
               case 115:
                  _loc10_.luckBoost_ = _loc4_;
                  continue;
               case 116:
                  _loc10_.setBronzeLootbox(_loc4_);
                  continue;
               case 117:
                  _loc10_.setSilverLootbox(_loc4_);
                  continue;
               case 118:
                  _loc10_.setGoldLootbox(_loc4_);
                  continue;
               case 119:
                  _loc10_.setEliteLootbox(_loc4_);
                  continue;
               case 120:
                  _loc10_.premiumLootbox_ = _loc4_;
                  continue;
               case 235:
                  _loc10_.setTrialLootbox(_loc4_);
                  continue;
               case 121:
                  _loc10_.restoration_ = _loc4_;
                  continue;
               case 122:
                  _loc10_.protection_ = _loc4_;
                  continue;
               case 123:
                  _loc10_.restorationBoost_ = _loc4_;
                  continue;
               case 124:
                  _loc10_.protectionBoost_ = _loc4_;
                  continue;
               case 125:
                  _loc10_.protectionPoints_ = _loc4_;
                  continue;
               case 126:
                  _loc10_.protectionPointsMax_ = _loc4_;
                  continue;
               case 127:
                  _loc10_.setEffect(_loc7_.strStatValue_);
                  continue;
               case 128:
                  _loc10_.marksEnabled_ = _loc4_ == 1;
                  if(param3)
                  {
                     this.updateMarkTab.dispatch(Boolean(_loc4_));
                  }
                  continue;
               case 146:
                  _loc10_.ascended = _loc4_ == 1;
                  continue;
               case 129:
                  _loc10_.mark_ = _loc4_;
                  continue;
               case 152:
                  _loc10_.storedPotions_ = _loc4_;
                  continue;
               case 130:
                  _loc10_.node1_ = _loc4_;
                  continue;
               case 131:
                  _loc10_.node2_ = _loc4_;
                  continue;
               case 132:
                  _loc10_.node3_ = _loc4_;
                  continue;
               case 133:
                  _loc10_.node4_ = _loc4_;
                  continue;
               case 147:
                  _loc10_.rage_ = _loc4_;
                  continue;
               case 148:
                  _loc10_.sorStorage_ = _loc4_;
                  continue;
               case 150:
                  _loc10_.elite_ = _loc4_;
                  continue;
               case 151:
                  _loc10_.pvp_ = _loc4_ == 1;
                  continue;
               case 155:
                  _loc10_.trialTokens_ = _loc4_;
                  continue;
               case 156:
                  _loc10_.mythQuest_ = _loc4_;
                  continue;
               case 234:
                  _loc10_.christmasPresents_ = _loc4_;
                  continue;
               case 204:
                  _loc10_.aspect = _loc4_;
                  continue;
               case 157:
                  _loc10_.mythQuestTrack_ = _loc4_;
                  continue;
               case 210:
                  _loc10_.SPS_Life = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 211:
                  _loc10_.SPS_Life_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 212:
                  _loc10_.SPS_Mana = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 213:
                  _loc10_.SPS_Mana_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 214:
                  _loc10_.SPS_Defense = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 215:
                  _loc10_.SPS_Defense_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 216:
                  _loc10_.SPS_Attack = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 217:
                  _loc10_.SPS_Attack_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 218:
                  _loc10_.SPS_Dexterity = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 219:
                  _loc10_.SPS_Dexterity_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 220:
                  _loc10_.SPS_Speed = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 221:
                  _loc10_.SPS_Speed_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 222:
                  _loc10_.SPS_Vitality = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 223:
                  _loc10_.SPS_Vitality_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 224:
                  _loc10_.SPS_Wisdom = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 225:
                  _loc10_.SPS_Wisdom_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 226:
                  _loc10_.SPS_Might = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 227:
                  _loc10_.SPS_Might_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 228:
                  _loc10_.SPS_Luck = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 229:
                  _loc10_.SPS_Luck_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 230:
                  _loc10_.SPS_Restoration = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 231:
                  _loc10_.SPS_Restoration_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 232:
                  _loc10_.SPS_Protection = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 233:
                  _loc10_.SPS_Protection_Max = _loc4_;
                  if(_loc10_.SPS_Modal != null)
                  {
                     _loc10_.SPS_Modal.draw();
                  }
                  continue;
               case 205:
                  param1.condition_[2] = _loc4_;
                  continue;
               case 81:
                  petId = _loc4_;
                  continue;
               case 23:
                  BattlePassModel.level = _loc4_;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 24:
                  BattlePassModel.currExp = _loc4_;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 25:
                  BattlePassModel.claimed = _loc7_.strStatValue_;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 64:
                  BattlePassModel.premium = _loc4_ != 0;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 82:
                  if(_loc4_ != -1 && BattlePassModel.respritesData[_loc4_] != null)
                  {
                     if((_loc5_ = BattlePassModel.respritesData[_loc4_]).specialAnimatedCharTexture != null)
                     {
                        param1.animatedChar_ = _loc5_.specialAnimatedCharTexture;
                     }
                     if(_loc5_.specialTexture != null)
                     {
                        param1.texture_ = _loc5_.specialTexture;
                     }
                     if(_loc5_.specialAnimationsData != null)
                     {
                        param1.animations_ = new Animations(_loc5_.specialAnimationsData);
                        param1.animatedChar_ = null;
                     }
                  }
                  continue;
               case 83:
                  _loc10_.starIconType = _loc4_;
                  continue;
               case 86:
                  _loc10_.ratBags = _loc4_;
                  continue;
               default:
                  continue;
            }
            _loc8_ = _loc7_.statType_ - 8;
            param1.equipment_[_loc8_] = new ItemData(_loc7_.strStatValue_);
            if(param1 is Container)
            {
               (param1 as Container).isChanged = true;
            }
         }
      }
      
      private function setPlayerSkinTemplate(param1:Player, param2:int) : void
      {
         var _loc3_:Reskin = this.messages.require(15) as Reskin;
         _loc3_.skinID = param2;
         _loc3_.player = param1;
         _loc3_.consume();
      }
      
      private function processObjectStatus(param1:ObjectStatusData, param2:int, param3:int) : void
      {
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc14_:int = 0;
         var _loc18_:* = null;
         var _loc17_:* = null;
         var _loc16_:* = null;
         var _loc15_:* = null;
         var _loc9_:int = 0;
         var _loc7_:* = null;
         var _loc5_:* = null;
         var _loc4_:* = null;
         var _loc13_:GameObject;
         var _loc12_:AbstractMap;
         if((_loc13_ = (_loc12_ = gs.map).goDict[param1.objectId_]) == null)
         {
            return;
         }
         var _loc10_:* = param1.objectId_ == this.playerId_;
         if(param2 != 0 && !_loc10_)
         {
            _loc13_.onTickPos(param1.pos_.x_,param1.pos_.y_,param2,param3);
         }
         var _loc11_:Player;
         if((_loc11_ = _loc13_ as Player) != null)
         {
            _loc6_ = _loc11_.level_;
            _loc8_ = _loc11_.exp_;
            _loc14_ = _loc11_.skinId;
         }
         this.updateGameObject(_loc13_,param1.stats_,_loc10_);
         if(_loc11_)
         {
            if(_loc10_)
            {
               if((_loc18_ = this.classesModel.getCharacterClass(_loc11_.objectType_)).getMaxLevelAchieved() < _loc11_.level_)
               {
                  _loc18_.setMaxLevelAchieved(_loc11_.level_);
               }
            }
            if(_loc11_.skinId != _loc14_)
            {
               if(ObjectLibrary.skinSetXMLDataLibrary_[_loc11_.skinId] != null)
               {
                  _loc16_ = (_loc17_ = ObjectLibrary.skinSetXMLDataLibrary_[_loc11_.skinId] as XML).attribute("color");
                  _loc15_ = _loc17_.attribute("bulletType");
                  if(_loc6_ != -1 && _loc16_.length > 0)
                  {
                     _loc11_.levelUpParticleEffect(uint(_loc16_));
                  }
                  if(_loc15_.length > 0)
                  {
                     _loc11_.projectileIdSetOverrideNew = _loc15_;
                     _loc9_ = _loc11_.equipment_[0].objectType;
                     _loc7_ = ObjectLibrary.propsLibrary_[_loc9_];
                     try
                     {
                        _loc5_ = _loc7_.projectiles_[0];
                        _loc11_.projectileIdSetOverrideOld = _loc5_.objectId_;
                     }
                     catch(ex:Error)
                     {
                     }
                  }
               }
               else if(ObjectLibrary.skinSetXMLDataLibrary_[_loc11_.skinId] == null)
               {
                  _loc11_.projectileIdSetOverrideNew = "";
                  _loc11_.projectileIdSetOverrideOld = "";
               }
            }
            if(_loc6_ != -1 && _loc11_.level_ > _loc6_)
            {
               if(_loc10_)
               {
                  _loc4_ = gs.model.getNewUnlocks(_loc11_.objectType_,_loc11_.level_);
                  _loc11_.handleLevelUp(_loc4_.length != 0);
               }
               else if(!Parameters.data.noAllyNotifications)
               {
                  _loc11_.levelUpEffect("Player.levelUp");
               }
            }
            else if(_loc6_ != -1 && _loc11_.exp_ > _loc8_ && (_loc10_ || !Parameters.data.noAllyNotifications))
            {
               _loc11_.handleExpUp(_loc11_.exp_ - _loc8_);
            }
         }
      }
      
      private function onInvResult(param1:InvResult) : void
      {
         if(param1.result_ != 0)
         {
            this.handleInvFailure();
         }
      }
      
      private function handleInvFailure() : void
      {
         SoundEffectLibrary.play("error");
         gs.hudView.interactPanel.redraw();
      }
      
      private function onReconnect(param1:Reconnect) : void
      {
         var _loc2_:Server = new Server().setName(param1.name_).setAddress(param1.host_ != "" ? param1.host_ : server_.address).setPort(param1.host_ != "" ? param1.port_ : int(server_.port));
         var _loc3_:int = param1.gameId_;
         var _loc7_:Boolean = createCharacter_;
         var _loc8_:int = charId_;
         var _loc5_:int = param1.keyTime_;
         var _loc6_:ByteArray = param1.key_;
         isFromArena_ = param1.isFromArena_;
         var _loc4_:ReconnectEvent = new ReconnectEvent(_loc2_,_loc3_,_loc7_,_loc8_,_loc5_,_loc6_,isFromArena_);
         gs.dispatchEvent(_loc4_);
      }
      
      private function reconnect2Nexus() : void
      {
         var _loc1_:Server = new Server().setName("Nexus").setAddress(server_.address).setPort(server_.port);
         var _loc2_:ReconnectEvent = new ReconnectEvent(_loc1_,-2,false,charId_,0,null,isFromArena_);
         gs.dispatchEvent(_loc2_);
      }
      
      private function onPing(param1:Ping) : void
      {
         var _loc2_:Pong = this.messages.require(64) as Pong;
         _loc2_.serial_ = param1.serial_;
         _loc2_.time_ = getTimer();
         serverConnection.sendMessage(_loc2_);
      }
      
      private function parseXML(param1:String) : void
      {
         var _loc2_:XML = XML(param1);
         GroundLibrary.parseFromXML(_loc2_);
         ObjectLibrary.parseFromXML(_loc2_);
      }
      
      private function onMapInfo(param1:MapInfo) : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         for each(_loc2_ in param1.clientXML_)
         {
            this.parseXML(_loc2_);
         }
         for each(_loc3_ in param1.extraXML_)
         {
            this.parseXML(_loc3_);
         }
         changeMapSignal.dispatch();
         this.closeDialogs.dispatch();
         gs.applyMapInfo(param1);
         this.rand_ = new Random(param1.fp_);
         Music.load(param1.music);
         if(createCharacter_)
         {
            this.create();
         }
         else
         {
            this.load();
         }
      }
      
      private function onPic(param1:Pic) : void
      {
         gs.addChild(new PicView(param1.bitmapData_));
      }
      
      private function onDeath(param1:Death) : void
      {
         this.death = param1;
         var _loc2_:BitmapData = new BitmapDataSpy(gs.stage.stageWidth,gs.stage.stageHeight);
         _loc2_.draw(gs);
         param1.background = _loc2_;
         if(!gs.isEditor)
         {
            this.handleDeath.dispatch(param1);
         }
         this.checkDavyKeyRemoval();
      }
      
      private function onBuyResult(param1:BuyResult) : void
      {
         outstandingBuy_ = false;
         this.handleBuyResultType(param1);
      }
      
      private function handleBuyResultType(param1:BuyResult) : void
      {
         var _loc2_:* = null;
         switch(int(param1.result_) - -1)
         {
            case 0:
               _loc2_ = ChatMessage.make("",param1.resultString_);
               this.addTextLine.dispatch(_loc2_);
               return;
            case 4:
               this.openDialog.dispatch(new NotEnoughGoldDialog());
               return;
            case 7:
               this.openDialog.dispatch(new NotEnoughFameDialog());
               return;
            default:
               this.handleDefaultResult(param1);
               return;
         }
      }
      
      private function handleDefaultResult(param1:BuyResult) : void
      {
         var _loc2_:LineBuilder = LineBuilder.fromJSON(param1.resultString_);
         var _loc3_:Boolean = param1.result_ == 0 || param1.result_ == 7;
         var _loc4_:ChatMessage;
         (_loc4_ = ChatMessage.make(!!_loc3_ ? "" : "*Error*",_loc2_.key)).tokens = _loc2_.tokens;
         this.addTextLine.dispatch(_loc4_);
      }
      
      private function onAccountList(param1:AccountList) : void
      {
         if(param1.accountListId_ == 0)
         {
            if(param1.lockAction_ != -1)
            {
               if(param1.lockAction_ == 1)
               {
                  gs.map.party.setStars(param1);
               }
               else
               {
                  gs.map.party.removeStars(param1);
               }
            }
            else
            {
               gs.map.party.setStars(param1);
            }
         }
         else if(param1.accountListId_ == 1)
         {
            gs.map.party.setIgnores(param1);
         }
      }
      
      private function onQuestObjId(param1:QuestObjId) : void
      {
         gs.map.quest.setObject(param1.objectId_);
      }
      
      private function onAoe(param1:Aoe) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = undefined;
         if(this.player == null)
         {
            this.aoeAck(gs.lastUpdate_,0,0);
            return;
         }
         var _loc2_:AOEEffect = new AOEEffect(param1.pos_.toPoint(),param1.radius_,16711680);
         gs.map.addObj(_loc2_,param1.pos_.x_,param1.pos_.y_);
         if(this.player.isInvincible() || this.player.isPaused())
         {
            this.aoeAck(gs.lastUpdate_,this.player.x_,this.player.y_);
            return;
         }
         var _loc3_:* = this.player.distTo(param1.pos_) < param1.radius_;
         if(_loc3_)
         {
            _loc4_ = GameObject.damageWithDefense(param1.damage_,this.player.defense_,false,this.player.condition_);
            _loc5_ = null;
            if(param1.effect_ != 0)
            {
               (_loc5_ = new Vector.<uint>()).push(param1.effect_);
            }
            this.player.damage(param1.origType_,_loc4_,_loc5_,false,null);
         }
         this.aoeAck(gs.lastUpdate_,this.player.x_,this.player.y_);
      }
      
      private function onNameResult(param1:NameResult) : void
      {
         gs.dispatchEvent(new NameResultEvent(param1));
      }
      
      private function onGuildResult(param1:GuildResult) : void
      {
         var _loc2_:* = null;
         if(param1.lineBuilderJSON == "")
         {
            gs.dispatchEvent(new GuildResultEvent(param1.success_,"",{}));
         }
         else
         {
            _loc2_ = LineBuilder.fromJSON(param1.lineBuilderJSON);
            this.addTextLine.dispatch(ChatMessage.make("*Error*",_loc2_.key,-1,-1,"",false,_loc2_.tokens));
            gs.dispatchEvent(new GuildResultEvent(param1.success_,_loc2_.key,_loc2_.tokens));
         }
      }
      
      private function onClientStat(param1:ClientStat) : void
      {
         var _loc2_:Account = StaticInjectorContext.getInjector().getInstance(Account);
         _loc2_.reportIntStat(param1.name_,param1.value_);
      }
      
      private function onFile(param1:File) : void
      {
         new FileReference().save(param1.file_,param1.filename_);
      }
      
      private function onInvitedToGuild(param1:InvitedToGuild) : void
      {
         if(Parameters.data.showGuildInvitePopup)
         {
            gs.hudView.interactPanel.setOverride(new GuildInvitePanel(gs,param1.name_,param1.guildName_));
         }
         this.addTextLine.dispatch(ChatMessage.make("","You have been invited by " + param1.name_ + " to join the guild " + param1.guildName_ + ".\n  If you wish to join type \"/join " + param1.guildName_ + "\""));
      }
      
      private function onPlaySound(param1:PlaySound) : void
      {
         var _loc2_:GameObject = gs.map.goDict[param1.ownerId_];
         _loc2_ && _loc2_.playSound(param1.soundId_);
      }
      
      private function onImminentArenaWave(param1:ImminentArenaWave) : void
      {
         this.imminentWave.dispatch(param1.currentRuntime);
      }
      
      private function onArenaDeath(param1:ArenaDeath) : void
      {
         this.currentArenaRun.costOfContinue = param1.cost;
         this.openDialog.dispatch(new ContinueOrQuitDialog(param1.cost,false));
         this.arenaDeath.dispatch();
      }
      
      private function onVerifyEmail(param1:VerifyEmail) : void
      {
         TitleView.queueEmailConfirmation = true;
         if(gs != null)
         {
            gs.closed.dispatch();
         }
         var _loc2_:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
         if(_loc2_ != null)
         {
            _loc2_.dispatch();
         }
      }
      
      private function onPasswordPrompt(param1:PasswordPrompt) : void
      {
         if(param1.cleanPasswordStatus == 3)
         {
            TitleView.queuePasswordPromptFull = true;
         }
         else if(param1.cleanPasswordStatus == 2)
         {
            TitleView.queuePasswordPrompt = true;
         }
         else if(param1.cleanPasswordStatus == 4)
         {
            TitleView.queueRegistrationPrompt = true;
         }
         if(gs != null)
         {
            gs.closed.dispatch();
         }
         var _loc2_:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
         if(_loc2_ != null)
         {
            _loc2_.dispatch();
         }
      }
      
      public function questFetch() : void
      {
         serverConnection.sendMessage(this.messages.require(51));
      }
      
      private function onQuestFetchResponse(param1:QuestFetchResponse) : void
      {
         this.questFetchComplete.dispatch(param1);
      }
      
      private function onQuestRedeemResponse(param1:QuestRedeemResponse) : void
      {
         this.questRedeemComplete.dispatch(param1);
      }
      
      public function questRedeem(param1:int, param2:int, param3:ItemData) : void
      {
         var _loc4_:QuestRedeem;
         (_loc4_ = this.messages.require(37) as QuestRedeem).slotObject.objectId_ = param1;
         _loc4_.slotObject.slotId_ = param2;
         _loc4_.slotObject.itemData_ = param3.toString();
         serverConnection.sendMessage(_loc4_);
      }
      
      public function keyInfoRequest(param1:int) : void
      {
         var _loc2_:KeyInfoRequest = this.messages.require(151) as KeyInfoRequest;
         _loc2_.itemType_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      private function onKeyInfoResponse(param1:KeyInfoResponse) : void
      {
         this.keyInfoResponse.dispatch(param1);
      }
      
      private function onClosed() : void
      {
         var _loc1_:* = null;
         if(this.playerId_ != -1)
         {
            gs.closed.dispatch();
         }
         else if(this.retryConnection_)
         {
            if(this.delayBeforeReconnect < 10)
            {
               if(this.delayBeforeReconnect == 6)
               {
                  _loc1_ = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
                  _loc1_.dispatch();
               }
               this.retry(this.delayBeforeReconnect++);
               this.addTextLine.dispatch(ChatMessage.make("*Error*","Connection failed!  Retrying..."));
            }
            else
            {
               gs.closed.dispatch();
            }
         }
      }
      
      private function retry(param1:int) : void
      {
         this.retryTimer_ = new Timer(param1 * 1000,1);
         this.retryTimer_.addEventListener("timerComplete",this.onRetryTimer);
         this.retryTimer_.start();
      }
      
      private function onRetryTimer(param1:TimerEvent) : void
      {
         serverConnection.connect(server_.address,server_.port);
      }
      
      private function onError(param1:String) : void
      {
         this.addTextLine.dispatch(ChatMessage.make("*Error*",param1));
      }
      
      private function onFailure(param1:Failure) : void
      {
         var _loc2_:Signal = this.injector.getInstance(HideMapLoadingSignal);
         _loc2_ && _loc2_.dispatch();
         switch(int(param1.errorId_) - 4)
         {
            case 0:
               this.handleIncorrectVersionFailure(param1);
               return;
            case 1:
               this.handleBadKeyFailure(param1);
               return;
            case 2:
               this.handleInvalidTeleportTarget(param1);
               return;
            case 3:
               this.handleEmailVerificationNeeded(param1);
               return;
            case 4:
               this.handleJsonDialog(param1);
               return;
            default:
               this.handleDefaultFailure(param1);
               return;
         }
      }
      
      private function handleJsonDialog(param1:Failure) : void
      {
         var _loc2_:* = null;
         var _loc3_:Object = JSON.parse(param1.errorDescription_);
         if("4.4.0" != _loc3_.build)
         {
            handleIncorrectVersionFailureBasic(_loc3_.build);
            return;
         }
         _loc2_ = new Dialog(_loc3_.title,_loc3_.description,"Ok",null,null);
         _loc2_.addEventListener("dialogLeftButton",this.onDoClientUpdate);
         this.gs.addChild(_loc2_);
         this.retryConnection_ = false;
      }
      
      private function handleEmailVerificationNeeded(param1:Failure) : void
      {
         this.retryConnection_ = false;
         gs.closed.dispatch();
      }
      
      private function handleInvalidTeleportTarget(param1:Failure) : void
      {
         var _loc2_:String = LineBuilder.getLocalizedStringFromJSON(param1.errorDescription_);
         if(_loc2_ == "")
         {
            _loc2_ = param1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make("*Error*",_loc2_));
         this.player.nextTeleportAt_ = 0;
      }
      
      private function handleBadKeyFailure(param1:Failure) : void
      {
         var _loc2_:String = LineBuilder.getLocalizedStringFromJSON(param1.errorDescription_);
         if(_loc2_ == "")
         {
            _loc2_ = param1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make("*Error*",_loc2_));
         this.retryConnection_ = false;
         gs.closed.dispatch();
      }
      
      private function handleIncorrectVersionFailure(param1:Failure) : void
      {
         handleIncorrectVersionFailureBasic(param1.errorDescription_);
      }
      
      private function handleIncorrectVersionFailureBasic(param1:String) : void
      {
         var _loc2_:Dialog = new Dialog("ClientUpdate.title","","ClientUpdate.leftButton",null,"/clientUpdate");
         _loc2_.setTextParams("ClientUpdate.description",{
            "client":"4.4.0",
            "server":param1
         });
         _loc2_.addEventListener("dialogLeftButton",this.onDoClientUpdate);
         this.gs.addChild(_loc2_);
         this.retryConnection_ = false;
      }
      
      private function handleDefaultFailure(param1:Failure) : void
      {
         var _loc2_:String = LineBuilder.getLocalizedStringFromJSON(param1.errorDescription_);
         if(_loc2_ == "")
         {
            _loc2_ = param1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make("*Error*",_loc2_));
      }
      
      private function onDoClientUpdate(param1:Event) : void
      {
         var _loc2_:Dialog = param1.currentTarget as Dialog;
         _loc2_.parent.removeChild(_loc2_);
         gs.closed.dispatch();
      }
      
      public function isConnected() : Boolean
      {
         return serverConnection.isConnected();
      }
      
      private function setFocus(param1:SetFocus) : void
      {
         var _loc3_:* = null;
         var _loc2_:Dictionary = this.gs.map.goDict;
         if(_loc2_)
         {
            _loc3_ = _loc2_[param1.objectId_];
            gs.setFocus(_loc3_);
            gs.hudView.setMiniMapFocus(_loc3_);
         }
      }
      
      public function requestMyMarketOffers() : void
      {
         var _loc1_:MarketCommand = this.messages.require(99) as MarketCommand;
         _loc1_.commandId = 0;
         serverConnection.sendMessage(_loc1_);
      }
      
      public function requestAllMarketOffers() : void
      {
         var _loc1_:MarketCommand = this.messages.require(99) as MarketCommand;
         _loc1_.commandId = 3;
         serverConnection.sendMessage(_loc1_);
      }
      
      public function removeMarketOffer(param1:Vector.<uint>) : void
      {
         var _loc2_:MarketCommand = this.messages.require(99) as MarketCommand;
         _loc2_.commandId = 2;
         _loc2_.offerIds = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      private function HandleMarketResult(param1:MarketResult) : void
      {
         switch(int(param1.commandId))
         {
            case 0:
            case 1:
               StaticInjectorContext.getInjector().getInstance(MarketResultSignal).dispatch(param1.message,param1.error);
               break;
            case 2:
               StaticInjectorContext.getInjector().getInstance(MarketItemsResultSignal).dispatch(param1.items);
         }
      }
      
      public function addOffer(param1:Vector.<MarketOffer>) : void
      {
         var _loc2_:* = null;
         _loc2_ = this.messages.require(99) as MarketCommand;
         _loc2_.commandId = 1;
         _loc2_.newOffers = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      public function lootNotif(param1:kabam.rotmg.messaging.impl.incoming.LootNotification) : void
      {
         if(gs.contains(gs.map.lootNotification))
         {
            gs.removeChild(gs.map.lootNotification);
         }
         gs.map.lootNotification = new com.company.assembleegameclient.ui.lootNotification.LootNotification();
         gs.addChild(gs.map.lootNotification);
         gs.map.lootNotification.show(param1.item);
      }
      
      public function claimBattlePassItem(param1:int, param2:Boolean) : void
      {
         var _loc3_:ClaimBattlePassItem = this.messages.require(179) as ClaimBattlePassItem;
         _loc3_.isPremium = param2;
         _loc3_.itemLevel = param1;
         serverConnection.sendMessage(_loc3_);
      }
      
      public function lockItem(param1:int, param2:int, param3:String) : void
      {
         var _loc4_:LockItem;
         (_loc4_ = this.messages.require(182) as LockItem).slotObject_ = new SlotObjectData();
         _loc4_.slotObject_.slotId_ = param1;
         _loc4_.slotObject_.objectId_ = param2;
         _loc4_.slotObject_.itemData_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      public function refreshMission(param1:int) : void
      {
         var _loc2_:RefreshMission = this.messages.require(184) as RefreshMission;
         _loc2_.missionId = param1;
         serverConnection.sendMessage(_loc2_);
      }
   }
}
