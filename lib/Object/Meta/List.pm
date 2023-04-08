#
# @author Bodo (Hugo) Barwich
# @version 2023-03-30
# @package Indexed List
# @subpackage lib/Object/Meta/List.pm

# This Module defines Classes to manage Data in an indexed List
#
#---------------------------------
# Requirements:
#
#---------------------------------
# Features:
# - Numerical Key Values in Object::Meta::List
# - Adding a Object::Meta Object to the Object::Meta::List by the Index Value
#


#==============================================================================
# The Object::Meta::List Package


package Object::Meta::List;

#----------------------------------------------------------------------------
#Dependencies

use parent 'Object::Meta';

use Scalar::Util 'blessed';

use constant LIST_ENTRIES => 2;
use constant LIST_ENTRIES_INDEXED => 3;

use constant PRIMARY_INDEXNAME => 'primary';



#----------------------------------------------------------------------------
#Constructors


sub new
{
  my $class = ref($_[0]) || $_[0];

  my $self = $class->SUPER::new(@_[1..$#_]);


  #Create the additional Entry Lists
  $self->[LIST_ENTRIES] = ();
  $self->[LIST_ENTRIES_INDEXED] = ();


  #Give the Object back
  return $self;
}

sub DESTROY
{
  my $self = $_[0];


  #Free the Entry Lists
  $self->[LIST_ENTRIES] = ();
  $self->[LIST_ENTRIES_INDEXED] = ();

  #Call Base Class Destructor
  $self->SUPER::DESTROY;
}



#----------------------------------------------------------------------------
#Administration Methods


sub setIndexField
{
  my ($self, $sindexname, $sindexfield) = @_;


  unless(defined $sindexfield)
  {
    $sindexfield = $sindexname;
    $sindexname = PRIMARY_INDEXNAME;
  }

  #print "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n";
  #print "" . (caller(0))[3] . " - idx nm: '$sindexname'; idx fld: '$sindexfield'\n";

  if(defined $sindexfield
    && $sindexfield ne "")
  {
    $self->createIndex(("indexname" => $sindexname, "checkfield" => $sindexfield));
  }
}

sub Add
{
  my $self = $_[0];
  my $mtaety = undef;


  if(scalar(@_) > 1)
  {
    if(defined blessed $_[1])
    {
      $mtaety = $_[1] ;
    }
    else  #Parameter is not an Object
    {
      if(scalar(@_) > 2)
      {
        #Create the new MetaEntry Object from the given Parameters
        $mtaety = Object::Meta::->new(@_[1..$#_]);
      }
      else  #A Single Scalar Parameter
      {
        #Create the new MetaEntry Object with the Index Value
        $mtaety = Object::Meta::->new($self->getIndexField, $_[1]);
      }
    } #if(defined blessed $_[1])
  } #if(scalar(@_) > 1)

  if(defined $mtaety)
  {
    unless($mtaety->isa("Object::Meta"))
    {
      $mtaety = undef;
    }
  } #if(defined $mtaety)

  $mtaety = Object::Meta::->new unless(defined $mtaety);

  if(defined $mtaety
    && $mtaety->isa("MetaEntry"))
  {
    my $ietycnt = $self->getMetaEntryCount;


    push @{$self->[LIST_ENTRIES]}, ($mtaety);

    $ietycnt = 0 if($ietycnt < 0);

    #Update the MetaEntry Count
    $self->setMeta("entrycount", $ietycnt + 1);

    #Add the the MetaEntry Object to the Index Lists
    $self->_indexMetaEntry($mtaety);

  } #if(defined $mtaety && $mtaety->isa("Object::Meta"))


  #Give the added MetaEntry Object back
  return $mtaety;
}

sub _indexMetaObject
{
  my ($self, $mtaety) = @_;


  if(defined $mtaety
    && $mtaety->isa('Object::Meta'))
  {
    my $hshidxcnfs = $self->getMeta('indexconfiguration', {});
    my $hshidxcnf = undef;
    my $iupdidxcnf = 0;

    my $slstmnidxvl = "";
    my $slstidxfld = "";
    my $slstidxvl = "";
    my $slstchkvl = "";


    foreach (keys %{$hshidxcnfs})
    {
      $hshidxcnf = $hshidxcnfs->{$_};

      if(defined $hshidxcnf)
      {
        $mtaety->setIndexField($hshidxcnf->{"indexfield"})
          if($hshidxcnf->{"name"} eq PRIMARY_INDEXNAME);

        $slstmnidxvl = $mtaety->get($hshidxcnf->{"indexfield"}, undef);
        $slstchkvl = $mtaety->get($hshidxcnf->{"checkfield"}, undef, $hshidxcnf->{"meta"});
        $slstidxvl = "";


        if(defined $slstchkvl
          && $slstchkvl ne "")
        {
          if($hshidxcnf->{"checkvalue"} ne "")
          {
            $slstidxvl = $slstmnidxvl
              if("$slstchkvl" eq $hshidxcnf->{"checkvalue"} . ""
                && defined $slstmnidxvl);

          }
          else  #Its not a by Value Index
          {
            $slstidxvl = $slstmnidxvl;
          }  #if($hshidxcnf->{"checkvalue"} ne "")
        } #if(defined $slstchkvl && $slstchkvl ne "")

        #print "idx nm: '$sindexname'; chk fld: '$sfldnm'; fld vl: '$slstchkvl'; idx vl: '$sidxvl'\n";

        if($slstidxvl ne "")
        {
          $self->[LIST_ENTRIES_INDEXED]{$hshidxcnf->{"name"}} = ()
            unless(defined $self->[LIST_ENTRIES_INDEXED]{$hshidxcnf->{"name"}});

          unless(defined $self->[LIST_ENTRIES_INDEXED]{$hshidxcnf->{"name"}}{$slstidxvl})
          {
            $self->[LIST_ENTRIES_INDEXED]{$hshidxcnf->{"name"}}{$slstidxvl} = $mtaety;

            #Count the Entries
            if(defined $hshidxcnf->{"count"}
              && $hshidxcnf->{"count"} > 0)
            {
              $hshidxcnf->{"count"}++;
            }
            else
            {
              $hshidxcnf->{"count"} = 1;
            }

            $iupdidxcnf = 1 unless($iupdidxcnf);

          }  #unless(defined $self->{"_list_entries_indexed"}{$hshidxcnf->{"name"}}{$slstidxvl})
        } #if($sidxvl ne "")

      } #if(defined $hshidxcnf)
    }  #foreach (keys %{$hshidxcnfs})

    if($iupdidxcnf)
    {
      $self->setMeta("indexconfiguration", $hshidxcnfs)
    } #if($iupdidxcnf)
  } #if(defined $mtaety && $mtaety->isa("MetaEntry"))
}

#  /**
#   * This Method configures an Index which organizes the DBEntry Objects according to the
#   * Value of a given Field.<br />
#   * After configuring the Index it builds it by calling the Method
#   * DBEntryList::buildIndex()<br />
#   * If <b>$sindexname</b> is empty the Index Name will automatically build and assigned.
#   * It will be a combination of <b>$sfieldname</b> and <b>$sfieldvalue</b> if set.<br />
#   * If <b>$sfieldvalue</b> is set the Index will contain the DBEntry Objects
#   * that have the given Value $sfieldvalue at the given Field $sfieldname.
#   * If $sfieldvalue is not set the Values of the DBEntry Objects must be unique or
#   * the Index will implode duplicate DBEntry Objects and skipping first duplicate DBEntry Objects.<br />
#   * If <b>$bsubset</b> is set the Index could contain only a Part of all DBEntry Objects
#   * in the List. This will prevent the Index from rechecked automatically.
#   * If <b>$sfieldvalue</b> is set it will be automatically activated.<br />
#   * This will add an Index Structure to the Meta Field <b>"indexconfiguration"</b> with
#   * these Fields:<br />
#   * - <b>indexconfiguration[\*name\*]["name"]</b>: The Name of the Index
#   * - <b>indexconfiguration[\*name\*]["fieldname"]</b>: The Name of the Entry Field
#   * - <b>indexconfiguration[\*name\*]["fieldvalue"]</b>: A required Value of the Entry Field
#   * for the DBEntry Object to be indexed
#   * - <b>indexconfiguration[\*name\*]["meta"]</b>: Whether the Field is a Meta Field   *
#   * @param string $sindexname The Index Name. If left empty automatically a Name will be assigned.
#   * @param string $sfieldname The Field Name where to index
#   * @param string $sfieldvalue The Field Value a DBEntry Object must have to be indexed
#   * @param boolean $bmeta Indicates whether the Field is a Meta Data Field.
#   * @param boolean $bsubset Indicates whether only a Part of all DBEntry Objects will be indexed
#   * @param boolean $brebuild Indicates whether the Index must be rebuild
#   * @see DBEntryList::buildIndex()
#   */
#  function createIndex($sindexname, $sfieldname, $sfieldvalue = ""
#    , $bmeta = false, $bsubset = false, $brebuild = false)
#  {
#//    echo __METHOD__ . " in - fld nm: '$sfieldname'; fld vl: '$sfieldvalue'; "
#//      . "mta: '" . (int)$bmeta . "; 'set: '" . (int)$bsubset . "'; 'rebld: '" . (int)$brebuild . "'\n";
#
#    if($sfieldname !== "")
#    {
#      $arridxcnfs = $this->getMetaData("indexconfiguration", array());
#      $sidxnm = $sindexname;
#      $bupdidxcnf = false;
#
#
#      if($sidxnm === "")
#      {
#        $sidxnm = $sfieldname;
#
#        if($sfieldvalue !== "")
#          $sidxnm .= "_" . $sfieldvalue;
#
#      } //if($sidxnm === "")
#
#      if(isset($sfieldvalue)
#        && $sfieldvalue !== "")
#        $bsubset = true;
#
#      if(isset($arridxcnfs)
#        && is_array($arridxcnfs))
#        if(isset($arridxcnfs[$sidxnm]))
#        {
#          if(!isset($arridxcnfs[$sidxnm]["name"])
#            || $arridxcnfs[$sidxnm]["name"] != $sidxnm)
#          {
#            $arridxcnfs[$sidxnm]["name"] = $sidxnm;
#            $bupdidxcnf = true;
#          } //if(!isset($arridxcnfs[$sidxnm]["name"])
#            //  || $arridxcnfs[$sidxnm]["name"] != $sidxnm)
#
#          if(!isset($arridxcnfs[$sidxnm]["fieldname"])
#            || $arridxcnfs[$sidxnm]["fieldname"] != $sfieldname)
#          {
#            $arridxcnfs[$sidxnm]["fieldname"] = $sfieldname;
#            $bupdidxcnf = true;
#          } //if(!isset($arridxcnfs[$sidxnm]["entryfield"])
#            //  || $arridxcnfs[$sidxnm]["fieldname"] != $sfieldname)
#
#          if(!isset($arridxcnfs[$sidxnm]["fieldvalue"])
#            || $arridxcnfs[$sidxnm]["fieldvalue"] != $sfieldvalue)
#          {
#            $arridxcnfs[$sidxnm]["fieldvalue"] = $sfieldvalue;
#            $bupdidxcnf = true;
#          } //if(!isset($arridxcnfs[$sidxnm]["fieldvalue"])
#            //  || $arridxcnfs[$sidxnm]["fieldvalue"] != $sfieldvalue)
#
#          if(!isset($arridxcnfs[$sidxnm]["meta"])
#            || $arridxcnfs[$sidxnm]["meta"] != $bmeta)
#          {
#            $arridxcnfs[$sidxnm]["meta"] = $bmeta;
#            $bupdidxcnf = true;
#          } //if(!isset($arridxcnfs[$sidxnm]["meta"])
#            //  || $arridxcnfs[$sidxnm]["meta"] != $bmeta)
#
#          if(!isset($arridxcnfs[$sidxnm]["subset"])
#            || $arridxcnfs[$sidxnm]["subset"] != $bsubset)
#          {
#            $arridxcnfs[$sidxnm]["subset"] = $bsubset;
#            $bupdidxcnf = true;
#          } //if(!isset($arridxcnfs[$sidxnm]["meta"]))
#
#          if(!isset($arridxcnfs[$sidxnm]["count"]))
#          {
#            $arridxcnfs[$sidxnm]["count"] = 0;
#            $bupdidxcnf = true;
#          } //if(!isset($arridxcnfs[$sidxnm]["count"]))
#        }
#        else  //The Index Configuration is new
#        {
#          $bupdidxcnf = true;
#
#          $arridxcnfs[$sidxnm]["name"] = $sidxnm;
#          $arridxcnfs[$sidxnm]["fieldname"] = $sfieldname;
#          $arridxcnfs[$sidxnm]["fieldvalue"] = $sfieldvalue;
#          $arridxcnfs[$sidxnm]["meta"] = $bmeta;
#          $arridxcnfs[$sidxnm]["subset"] = $bsubset;
#          $arridxcnfs[$sidxnm]["count"] = 0;
#        } //if(!isset($arridxcnfs[$sidxnm]))
#
#      if($bupdidxcnf)
#      {
#        $this->setMetaData("indexconfiguration", $arridxcnfs);
#
#        $brebuild = true;
#      } //if($bupdidxcnf)
#
#      //Build the Index and fill it with DBEntry Objects
#      $this->buildIndex($sidxnm, $brebuild);
#
#    }  //if($sfieldname !== "")
#
#  }  //function createIndex($sfieldname)

sub createIndex
{
  my $self = shift;

  #Take the Method Parameters and set Default Values
  my %hshprms = ("indexname" => "", "indexfield" => ""
    , "checkfield" => "", "checkvalue" => ""
    , "meta" => 0, "subset" => 0, "rebuild" => 0
    , @_);



  if($hshprms{"checkfield"} ne "")
  {
    my $hshidxcnfs = $self->getMeta("indexconfiguration", {});
    my $sidxnm = $hshprms{"indexname"};
    my $iupdidxcnf = 0;


    unless(defined $sidxnm
      && $sidxnm ne "")
    {
      $sidxnm = $hshprms{"checkfield"};

      $sidxnm .= "_" . $hshprms{"checkvalue"}
        if(defined $hshprms{"checkvalue"}
          && $hshprms{"checkvalue"} ne "");

    } #unless(defined $sidxnm && $sidxnm ne "")

    unless(defined $hshprms{"indexfield"}
      && $hshprms{"indexfield"} ne "")
    {
      if(defined $hshprms{"checkvalue"}
        && $hshprms{"checkvalue"} ne "")
      {
        $hshprms{"indexfield"} = $self->getIndexField;
      }
      else
      {
        $hshprms{"indexfield"} = $hshprms{"checkfield"};
      }
    } #unless(defined $hshprms{"indexfield"} && $hshprms{"indexfield"} ne "")

    $hshprms{"subset"} = 1
      if(defined $hshprms{"checkvalue"}
        && $hshprms{"checkvalue"} ne "");

    %{$hshidxcnfs} = () unless(defined $hshidxcnfs);

    if(defined $hshidxcnfs->{$sidxnm})
    {
      unless(defined $hshidxcnfs->{$sidxnm}{"name"}
        && $hshidxcnfs->{$sidxnm}{"name"} eq $sidxnm)
      {
        $hshidxcnfs->{$sidxnm}{"name"} = $sidxnm;
        $iupdidxcnf = 1;
      }

      unless(defined $hshidxcnfs->{$sidxnm}{"indexfield"}
        && $hshidxcnfs->{$sidxnm}{"indexfield"} eq $hshprms{"indexfield"})
      {
        $hshidxcnfs->{$sidxnm}{"indexfield"} = $hshprms{"indexfield"};
        $iupdidxcnf = 1;
      }

      unless(defined $hshidxcnfs->{$sidxnm}{"checkfield"}
        && $hshidxcnfs->{$sidxnm}{"checkfield"} eq $hshprms{"checkfield"})
      {
        $hshidxcnfs->{$sidxnm}{"checkfield"} = $hshprms{"checkfield"};
        $iupdidxcnf = 1;
      }

      unless(defined $hshidxcnfs->{$sidxnm}{"checkvalue"}
        && $hshidxcnfs->{$sidxnm}{"checkvalue"} eq $hshprms{"checkvalue"})
      {
        $hshidxcnfs->{$sidxnm}{"checkvalue"} = $hshprms{"checkvalue"};
        $iupdidxcnf = 1;
      }

      unless(defined $hshidxcnfs->{$sidxnm}{"meta"}
        && $hshidxcnfs->{$sidxnm}{"meta"} == $hshprms{"meta"})
      {
        $hshidxcnfs->{$sidxnm}{"meta"} = $hshprms{"meta"};
        $iupdidxcnf = 1;
      }

      unless(defined $hshidxcnfs->{$sidxnm}{"subset"}
        && $hshidxcnfs->{$sidxnm}{"subset"} == $hshprms{"subset"})
      {
        $hshidxcnfs->{$sidxnm}{"subset"} = $hshprms{"subset"};
        $iupdidxcnf = 1;
      }

      unless(defined $hshidxcnfs->{$sidxnm}{"count"})
      {
        $hshidxcnfs->{$sidxnm}{"count"} = 0;
        $iupdidxcnf = 1;
      }
    }
    else  #The Index Definition does not exist yet
    {
      $iupdidxcnf = 1;

      $hshidxcnfs->{$sidxnm}{"name"} = $sidxnm;
      $hshidxcnfs->{$sidxnm}{"indexfield"} = $hshprms{"indexfield"};
      $hshidxcnfs->{$sidxnm}{"checkfield"} = $hshprms{"checkfield"};
      $hshidxcnfs->{$sidxnm}{"checkvalue"} = $hshprms{"checkvalue"};
      $hshidxcnfs->{$sidxnm}{"meta"} = $hshprms{"meta"};
      $hshidxcnfs->{$sidxnm}{"subset"} = $hshprms{"subset"};
      $hshidxcnfs->{$sidxnm}{"count"} = 0;
    } #if(defined $hshidxcnfs->{$sidxnm})

    if($iupdidxcnf)
    {
      $self->setMeta("indexconfiguration", $hshidxcnfs);

      $hshprms{"rebuild"} = 1;
    } #if($iupdidxcnf)

    #Build the Index and fill it with MetaEntry Objects
    $self->buildIndex($sidxnm, $hshprms{"rebuild"});

  } #if($hshprms{"checkfield"} ne "")
}




#  /**
#   * This Method will actually build the Index and organize the DBEntry Objects in it.<br />
#   * It requires the previous call of DBEntryList::createIndex() to configure the Index.<br />
#   * @param string $sindexname The Index Name which was previously configured
#   * @param boolean $brebuild Indicates whether the Index must be rebuild
#   * @see DBEntryList::createIndex()
#   */
#  function buildIndex($sindexname, $brebuild = false)
#  {
#    //echo __METHOD__ . " - idx: '$sindexname', rbd: '" . (int)$brebuild . "'. go ...\n";
#
#    if(isset($sindexname)
#      && $sindexname !== "")
#    {
#      $arridxcnfs = $this->getMetaData("indexconfiguration", array());
#      $sfldnm = "";
#      $sfldvl = "";
#      $iidxcnt = -1;
#      $bmta = false;
#      $bsbset = false;
#      $bupdidxcnf = false;
#
#
#      if(isset($arridxcnfs[$sindexname]))
#      {
#        if(isset($arridxcnfs[$sindexname]["fieldname"]))
#          $sfldnm = $arridxcnfs[$sindexname]["fieldname"];
#
#        if($sfldnm === "")
#          if(isset($arridxcnfs[$sindexname]["entryfield"]))
#            $sfldnm = $arridxcnfs[$sindexname]["entryfield"];
#
#        if(isset($arridxcnfs[$sindexname]["fieldvalue"]))
#          $sfldvl = $arridxcnfs[$sindexname]["fieldvalue"];
#
#        if(isset($arridxcnfs[$sindexname]["meta"]))
#          $bmta = $arridxcnfs[$sindexname]["meta"];
#
#        if(isset($arridxcnfs[$sindexname]["subset"]))
#          $bsbset = $arridxcnfs[$sindexname]["subset"];
#
#        if(isset($arridxcnfs[$sindexname]["count"]))
#          $iidxcnt = $arridxcnfs[$sindexname]["count"];
#
#      } //if(isset($arridxcnfs[$sindexname]))
#
#      //echo "fld nm: '$sfldnm'; fld vl: '$sfldvl'; mta: '" . (int)$bmta . "'; set: '" . (int)$bsbset . "'\n";
#
#      if($sfldnm !== "")
#      {
#        $sidxvl = "";
#        $ietycnt = $this->getDBEntryCount();
#        //Check the Index when the List was updated
#        $bbld = $this->isUpdated();
#
#        if($brebuild)
#        {
#          if(isset($this->arridxetys[$sindexname]))
#          {
#            unset($this->arridxetys[$sindexname]);
#            $this->arridxetys[$sindexname] = array();
#          } //if(isset($this->arridxetys[$sidxnm]))
#
#          $iidxcnt = 0;
#          $bupdidxcnf = true;
#
#          //Check the Index
#          $bbld = true;
#        } //if($brebuild)
#
#        if(isset($this->arridxetys[$sindexname]))
#        {
#          if($iidxcnt < 0)
#            //Check the Index
#            $bbld = true;
#
#        }
#        else  //The Index still doesn't exist
#        {
#          $this->arridxetys[$sindexname] = array();
#
#          //Check the Index
#          $bbld = true;
#        }  //if(!isset($this->arridxetys[$sindexname]))
#
#        if(!$bsbset)
#          $bbld = ($bbld || $ietycnt != $iidxcnt);
#
#        //echo "ety cnt: '$ietycnt'; idx ety cnt: '$iidxcnt'; bld: '" . (int)$bbld . "'\n";
#
#        if($bbld)
#        {
#          if($ietycnt > 0)
#          {
#            $ety = NULL;
#            $ilstetyid = -1;
#            $slstfldvl = NULL;
#            $iidxcnt = 0;
#
#
#            for($iety = 0; $iety < $ietycnt; $iety++)
#            {
#              $ety = $this->arretys[$iety];
#              $sidxvl = "";
#
#              if(isset($ety))
#              {
#                $ilstetyid = $ety->getID();
#                $slstfldvl = $ety->get($sfldnm, NULL, $bmta);
#
#                if(isset($slstfldvl)
#                  && $slstfldvl !== "")
#                {
#                  if($sfldvl !== "")
#                  {
#                    if($slstfldvl == $sfldvl
#                      && isset($ilstetyid))
#                      $sidxvl = $ilstetyid;
#
#                  }
#                  else  //if($sfldvl !== "")
#                    $sidxvl = $slstfldvl;
#
#                } //if(isset($slstfldvl) && $slstfldvl !== "")
#
#                //echo "idx nm: '$sindexname'; fld nm: '$sfldnm'; fld vl: '$slstfldvl'; idx vl: '$sidxvl'\n";
#
#                if($sidxvl !== "")
#                  if(!isset($this->arridxetys[$sindexname][$sidxvl]))
#                  {
#                    $this->arridxetys[$sindexname][$sidxvl] = $ety;
#
#                    //Count the Entries
#                    $iidxcnt += 1;
#
#                    if(!$bupdidxcnf)
#                      $bupdidxcnf = true;
#
#                  }  //if(!isset($this->arridxetys[$sindexname][$sidxvl]))
#
#              } //if(isset($ety))
#            } //for($iety = 0; $iety < $ietycnt; $iety++)
#          } //if($ietycnt > 0)
#        } //if($bbld)
#      } //if($sfldnm !== "")
#
#      if($bupdidxcnf)
#      {
#        $arridxcnfs[$sindexname]["count"] = $iidxcnt;
#
#        $this->setMetaData("indexconfiguration", $arridxcnfs);
#      } //if($bupdidxcnf)
#    } //if(isset($sindexname) && $sindexname !== "")
#  }

sub buildIndex
{
  my $self = shift;
  my $sindexname = shift;
  my $irebuild = shift || 0;


  $sindexname = PRIMARY_INDEXNAME unless(defined $sindexname);

  #print "" .(caller(0))[3] . " - idx: '$sindexname', rbd: '$irebuild'. go ...\n";

  if(defined $sindexname
    && $sindexname ne "")
  {
    my $hshidxcnfs = $self->getMeta("indexconfiguration", {});
    my $hshidxcnf = undef;
    my $sidxvl = "";
    my $iidxcnt = -1;
    my $iupdidxcnf = 0;


    $hshidxcnf = $hshidxcnfs->{$sindexname}
      if(defined $hshidxcnfs->{$sindexname});

    if(defined $hshidxcnf
      && defined $hshidxcnf->{"checkfield"})
    {
      unless(defined $hshidxcnf->{"indexfield"}
        && $hshidxcnf->{"indexfield"} ne "")
      {
        $hshidxcnf->{"indexfield"} = $hshidxcnf->{"checkfield"};

        $iupdidxcnf = 1;
      }

      $iidxcnt = $hshidxcnf->{"count"}
        if(defined $hshidxcnf->{"count"});

    } #if(defined $hshidxcnf && defined $hshidxcnf->{"checkfield"})

    #print "idx fld: '$sidxfld'; chk fld: '$schkfld'; chk vl: '$schkvl'"
    #  . "; mta: '$imta'; set: '$isbset'\n";

    if(defined $hshidxcnf
      && defined $hshidxcnf->{"checkfield"}
      && $hshidxcnf->{"checkfield"} ne "")
    {
      my $ietycnt = $self->getMetaEntryCount;
      #Check the Index when the List was updated or when the Index was changed
      my $ibld = $iupdidxcnf;


      if($irebuild)
      {
        if(defined $self->[LIST_ENTRIES_INDEXED]{$sindexname})
        {
          $self->[LIST_ENTRIES_INDEXED]{$sindexname} = ();
        } #if(defined $self->{"_list_entries_indexed"}{$sindexname})

        $iidxcnt = 0;
        $iupdidxcnf = 1;

        #Check the Index
        $ibld = 1;
      } #if($irebuild)

      if(defined $self->[LIST_ENTRIES_INDEXED]{$sindexname})
      {
        #Check the Index
        $ibld = 1 if($iidxcnt < 0);
      }
      else  #The Index still doesn't exist
      {
        $self->[LIST_ENTRIES_INDEXED]{$sindexname} = ();

        #Check the Index
        $ibld = 1;
      }  #if(defined $self->{"_list_entries_indexed"}{$sindexname})

      if($ietycnt > 0)
      {
        unless($hshidxcnf->{"subset"})
        {
          $ibld = 1 if($ibld || $ietycnt != $iidxcnt);
        } #unless($hshidxcnf->{"subset"})
      }
      else  #There aren't any MetaEntries in the List
      {
        $ibld = 0;
      } #if($ietycnt > 0)

      #print "ety cnt: '$ietycnt'; idx ety cnt: '$iidxcnt'; bld: '$ibld'\n";

      if($ibld)
      {
        my $ety = undef;
        my $sidxvl = "";
        my $slstetyidxvl = "";
        my $slstchkvl = undef;
        my $iety = -1;


        $iidxcnt = 0;

        for($iety = 0; $iety < $ietycnt; $iety++)
        {
          $ety = $self->[LIST_ENTRIES][$iety];
          $sidxvl = "";

          if(defined $ety)
          {
            $slstetyidxvl = $ety->get($hshidxcnf->{"indexfield"}, undef);
            $slstchkvl = $ety->get($hshidxcnf->{"checkfield"}, undef, $hshidxcnf->{"meta"});

            if(defined $slstchkvl
              && $slstchkvl ne "")
            {
              if($hshidxcnf->{"checkvalue"} ne "")
              {
                $sidxvl = $slstetyidxvl
                  if("$slstchkvl" eq $hshidxcnf->{"checkvalue"} . ""
                    && defined $slstetyidxvl);

              }
              else  #Its not a by Value Index
              {
                $sidxvl = $slstetyidxvl;
              }  #if($sfldvl ne "")
            } #if(defined $slstchkvl && $slstchkvl ne "")

            #print "idx nm: '$sindexname'; chk fld: '$schkfld'; fld vl: '$slstchkvl'; idx vl: '$sidxvl'\n";

            if($sidxvl ne "")
            {
              unless(defined $self->[LIST_ENTRIES_INDEXED]{$sindexname}{$sidxvl})
              {
                $self->[LIST_ENTRIES_INDEXED]{$sindexname}{$sidxvl} = $ety;

                #Count the Entries
                $iidxcnt++;

                $iupdidxcnf = 1 unless($iupdidxcnf);

              }  #unless(defined $self->[LIST_ENTRIES_INDEXED]{$sindexname}{$sidxvl})
            } #if($sidxvl ne "")
          } #if(defined $ety)
        } #for($iety = 0; $iety < $ietycnt; $iety++)
      } #if($ibld)
    } #if(defined $hshidxcnf && defined $hshidxcnf->{"checkfield"}
      # && $hshidxcnf->{"checkfield"} ne "")


    if($iupdidxcnf)
    {
      $hshidxcnfs->{$sindexname}{"count"} = $iidxcnt;

      $self->setMeta("indexconfiguration", $hshidxcnfs)
    } #if($iupdidxcnf)
  } #if(defined $sindexname && $sindexname ne "")

}

sub buildIndexAll
{
  my $self = shift;
  my $irebuild = shift || 0;

  my $ietycnt = $self->getMetaEntryCount;

  my $hshidxcnfs = $self->getMeta("indexconfiguration", {});
  my $hshidxcnf = undef;
  my $sidxnm = "";
  my $iidxcnt = -1;

  my $ibld = 0;


  if(scalar(keys %$hshidxcnfs) > 0)
  {
    foreach $sidxnm (keys %{$hshidxcnfs})
    {
      $hshidxcnf = $hshidxcnfs->{$sidxnm};

      if(defined $hshidxcnf)
      {
        unless(defined $hshidxcnf->{"indexfield"}
          && $hshidxcnf->{"indexfield"} ne "")
        {
          $hshidxcnf->{"indexfield"} = $hshidxcnf->{"checkfield"};

          $ibld = 1;
        } #unless(defined $hshidxcnf->{"indexfield"} && $hshidxcnf->{"indexfield"} ne "")

        $iidxcnt = $hshidxcnf->{"count"}
          if(defined $hshidxcnf->{"count"});

      } #if(defined $hshidxcnf)

      if($irebuild)
      {
        if(defined $self->[LIST_ENTRIES_INDEXED]{$sidxnm})
        {
          $self->[LIST_ENTRIES_INDEXED]{$sidxnm} = ();
        } #if(defined $self->[LIST_ENTRIES_INDEXED]{$sidxnm})

        $hshidxcnf->{"count"} = 0;

        #Check the Index
        $ibld = 1;
      } #if($irebuild)

      if(defined $self->[LIST_ENTRIES_INDEXED]{$sidxnm})
      {
        #Check the Index
        $ibld = 1 if($iidxcnt < 0);
      }
      else  #The Index still doesn't exist
      {
        $self->[LIST_ENTRIES_INDEXED]{$sidxnm} = ();

        #Check the Index
        $ibld = 1;
      }  #if(defined $self->{"_list_entries_indexed"}{$sidxnm})

      if($ietycnt > 0)
      {
        unless($hshidxcnf->{"subset"})
        {
          $ibld = 1 if($ibld || $ietycnt != $iidxcnt);
        } #unless($hshidxcnf->{"subset"})
      } #if($ietycnt > 0)

      #print "idx nm: '$sidxnm'; idx ety cnt: '$iidxcnt'; bld: '$ibld'\n";

    } #foreach $sidxnm (keys %{$hshidxcnfs})

  } #if(scalar(keys %$hshidxcnfs) > 0)

  #print "ety cnt: '$ietycnt'; bld: '$ibld'\n";

  if($ibld)
  {
    my $ety = undef;
    my $sidxvl = "";
    my $slstetyidxvl = "";
    my $slstchkvl = undef;
    my $iety = -1;


    foreach $sidxnm (keys %{$hshidxcnfs})
    {
      $hshidxcnfs->{$sidxnm}{"count"} = 0;
    }

    for($iety = 0; $iety < $ietycnt; $iety++)
    {
      $ety = $self->[LIST_ENTRIES][$iety];
      $sidxvl = "";

      if(defined $ety)
      {
        foreach $sidxnm (keys %{$hshidxcnfs})
        {
          $hshidxcnf = $hshidxcnfs->{$sidxnm};

          $slstetyidxvl = $ety->get($hshidxcnf->{"indexfield"}, undef);
          $slstchkvl = $ety->get($hshidxcnf->{"checkfield"}, undef, $hshidxcnf->{"meta"});
          $sidxvl = '';

          if(defined $slstchkvl
            && $slstchkvl ne "")
          {
            if($hshidxcnf->{"checkvalue"} ne "")
            {
              $sidxvl = $slstetyidxvl
                if("$slstchkvl" eq $hshidxcnf->{"checkvalue"} . ""
                  && defined $slstetyidxvl);

            }
            else  #Its not a by Value Index
            {
              $sidxvl = $slstetyidxvl;
            }  #if($sfldvl ne "")
          } #if(defined $slstchkvl && $slstchkvl ne "")

          #print "idx nm: '$sindexname'; chk fld: '$schkfld'; fld vl: '$slstchkvl'; idx vl: '$sidxvl'\n";

          if($sidxvl ne "")
          {
            unless(defined $self->[LIST_ENTRIES_INDEXED]{$sidxnm}{$sidxvl})
            {
              $self->[LIST_ENTRIES_INDEXED]{$sidxnm}{$sidxvl} = $ety;

              #Count the Entries
              $hshidxcnf->{"count"}++;

              $iupdidxcnf = 1 unless($iupdidxcnf);

            }  #unless(defined $self->[LIST_ENTRIES_INDEXED]{$sindexname}{$sidxvl})
          } #if($sidxvl ne "")
        } #foreach $sidxnm (keys %{$hshidxcnfs})
      } #if(defined $ety)
    } #for($iety = 0; $iety < $ietycnt; $iety++)
  } #if($ibld)

  if($iupdidxcnf)
  {
    $self->setMeta("indexconfiguration", $hshidxcnfs)
  } #if($iupdidxcnf)
}

sub Clear
{
  my $self = $_[0];
  my $hshidxcnfs = $self->getMeta("indexconfiguration", {});


  #Execute the Base Class Logic
  $self->SUPER::Clear;

  #Save the Index Configuration
  $self->setMeta("indexconfiguration", $hshidxcnfs);

  #Clear the Object List too
  $self->clearList;
}

sub clearList
{
  my $self = $_[0];
  my $hshidxcnfs = $self->getMeta('indexconfiguration', {});


  #Clear the Entry Lists
  $self->[LIST_ENTRIES] = ();
  $self->[LIST_ENTRIES_INDEXED] = ();


  foreach (keys %{$hshidxcnfs})
  {
    $hshidxcnfs->{$_}{"count"} = 0;
  }
}

sub clearLists
{
  goto &clearList;
}



#----------------------------------------------------------------------------
#Consultation Methods


sub getIndexField
{
  my ($self, $sindexname) = @_;
  my $sindexfield = "";
  my $hshidxcnfs = $self->getMeta("indexconfiguration", {});



  $sindexname = PRIMARY_INDEXNAME unless(defined $sindexname);

  if(defined $hshidxcnfs->{$sindexname})
  {
    $sindexfield = $hshidxcnfs->{$sindexname}{"indexfield"}
      if(defined $hshidxcnfs->{$sindexname}{"indexfield"});

  }


  return $sindexfield;
}

sub getMetaObject
{
  my ($self, $iindex) = @_[0..1];
  my $rsety = undef;


  if(defined $iindex)
  {
    if($iindex =~ /^\-?\d+$/)
    {
      if($iindex > -1
        && $iindex < scalar(@{$self->[LIST_ENTRIES]}))
      {
        $rsety = $self->[LIST_ENTRIES][$iindex];
      }
    }
    else  #The Index Value is a Text
    {
      #For a Indexed MetaEntry Lookup there need to be more parameters
      $rsety = $self->getIdxMetaEntry($iindex, @_[2..$#_]);
    } #if($iindex =~ /^\-?\d+$/)
  } #if(defined $iindex)


  return $rsety;
}

sub getIdxMetaObject
{
  my ($self, $sindexname, $sindexvalue) = @_;
  my $rsety = undef;


  unless(defined $sindexvalue)
  {
    $sindexvalue = $sindexname;
    $sindexname = PRIMARY_INDEXNAME;
  }

  #print "idx nm: '$sindexname'; idx vl: '$sindexvalue'\n";

  if($sindexname ne ""
    && defined $self->[LIST_ENTRIES_INDEXED]{$sindexname})
  {
    $rsety = $self->[LIST_ENTRIES_INDEXED]{$sindexname}{$sindexvalue}
      if(defined $self->[LIST_ENTRIES_INDEXED]{$sindexname}{$sindexvalue});

  } #if($sindexname ne "" && defined $self->[LIST_ENTRIES_INDEXED]{$sindexname})


  return $rsety;
}


=pod

=over 4

=item getMetaObjectCount

This Method gives the Count of C<Object::Meta> objects back that are hold in the List.
If the B<Meta Data Field> C<entrycount> is not set it will be created.

B<Returns:> integer - The Count of C<Object::Meta> objects in the List

=back

=cut

sub getMetaObjectCount
{
  my $self = $_[0];
  my $irscnt = $self->getMeta('entrycount', -1);


  if($irscnt < 0)
  {
    if(defined $self->[LIST_ENTRIES])
    {
      $irscnt = scalar(@{$self->[LIST_ENTRIES]});
    }
    else
    {
      $irscnt = 0;
    }

    $self->setMeta('entrycount', $irscnt);
  } #if($irscnt < 0)


  return $irscnt;
}

sub getIdxMetaObjectCount
{
  my ($self, $sindexname) = @_;
  my $irscnt = -1;

  my $hshidxcnfs = $self->getMeta('indexconfiguration', {});


  $sindexname = PRIMARY_INDEXNAME unless(defined $sindexname);

  if($sindexname ne ''
    && defined $hshidxcnfs->{$sindexname})
  {
    $irscnt = $hshidxcnfs->{$sindexname}{"count"};
  }

  if($irscnt < 0
    && defined $hshidxcnfs->{$sindexname})
  {
    $irscnt = scalar(keys %{$self->[LIST_ENTRIES_INDEXED]{$sindexname}})
      if(defined $self->[LIST_ENTRIES_INDEXED]{$sindexname});

    if($irscnt > 0)
    {
      $hshidxcnfs->{$sindexname}{"count"} = $irscnt;

      $self->setMeta("indexconfiguration", $hshidxcnfs)
    } #if($irscnt > 0)
  } #if($irscnt < 0 && defined $hshidxcnfs->{$sindexname})


  return $irscnt;
}

sub getIdxValueArray
{
  my $self = shift;
  my $sindexname = shift;
  my @arrrs = undef;


  $sindexname = PRIMARY_INDEXNAME unless(defined $sindexname);

  if($sindexname ne ""
    && defined $self->[LIST_ENTRIES_INDEXED]{$sindexname})
  {
    @arrrs = keys %{$self->[LIST_ENTRIES_INDEXED]{$sindexname}};
  }
  else
  {
    @arrrs = ();
  } #if($sindexname ne "" && defined $self->[LIST_ENTRIES_INDEXED]{$sindexname})


  return (@arrrs);
}


return 1;
