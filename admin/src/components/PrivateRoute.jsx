import { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { Outlet, useNavigate } from 'react-router-dom'
import { getMe } from '../features/authSlice'
import Loading from './Loading'

const ProtectedRoute = () => {
  const dispatch = useDispatch()
  const navigate = useNavigate()
  const { user, isLoading, isError } = useSelector((state) => state.auth)

  useEffect(() => {
    dispatch(getMe())
  }, [dispatch])

  useEffect(() => {
    if (!isLoading && !user) {
      navigate('/')
    }
  }, [isLoading, user, navigate])

  if (isLoading) {
    return (
      <Loading />
    )
  }

  if (isError || !user) {
    return null
  }

  return <Outlet />
}

export default ProtectedRoute