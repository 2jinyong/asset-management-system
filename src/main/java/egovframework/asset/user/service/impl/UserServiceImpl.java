package egovframework.asset.user.service.impl;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.asset.user.service.UserMapper;
import egovframework.asset.user.service.UserService;
import egovframework.asset.user.service.UserVO;

@Service("userService")
public class UserServiceImpl extends EgovAbstractServiceImpl implements UserService{

	@Resource(name = "userMapper")
	private UserMapper userMapper;
	
	@Override
	public int insertUser(UserVO userVO) {
		return userMapper.insertUser(userVO);
	}

	
}
