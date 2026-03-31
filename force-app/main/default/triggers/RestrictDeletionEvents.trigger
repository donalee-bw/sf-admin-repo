trigger RestrictDeletionEvents on Event (before delete){

    String ProfileId = UserInfo.getProfileId();
    String RoleId =  UserInfo.getUserRoleId();

    System.debug('>>>> ProfileId '+ ProfileId);
    System.debug('>>>> RoleId '+ RoleId);

    List<Profile> profiles = [select id from Profile where name = 'System Administrator'];
    List<UserRole> roles = [select id, name from UserRole where name = 'Business and Data Operations' or name = 'Outbound SDR Manager 0'];

    System.debug('>>>> profiles '+ profiles);
    System.debug('>>>> roles '+ roles);

    for(Event e : Trigger.old){            
        if(profileId != profiles[0].id && (RoleId != roles[0].id && RoleId != roles[1].id))
        {
            e.addError('You can\'t delete this record.'); 
        }
    }            
}