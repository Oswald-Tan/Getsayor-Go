package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupWebRoutes(router *gin.Engine, db *gorm.DB) {
	apiGroup := router.Group("/api/v1")
	{
		setupAuthRoutes(apiGroup, db)
		setupUserStatsRoutes(apiGroup, db)
		setupUserRoutes(apiGroup, db)
		setupTopUpWebRoutes(apiGroup, db)
		setupProvinceCityRoutes(apiGroup, db)
		setupPoinRoutes(apiGroup, db)
		setupProductRoutes(apiGroup, db)
		setupSettingRoutes(apiGroup, db)
		SetupHargaPoinRoutes(apiGroup, db)
		setupShippingRateRoutes(apiGroup, db)
		SetupPesananRoutes(apiGroup, db)
		setupAfiliasiBonusRoutes(apiGroup, db)
		setupTotalWebRoutes(apiGroup, db)
	}
}
