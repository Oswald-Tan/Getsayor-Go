package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupAfiliasiBonusRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	bonusController := web.NewAfiliasiBonusController(db)

	bonusGroup := rg.Group("/afiliasi-bonus")
	{
		bonusGroup.GET("",
			middleware.VerifyUser,
			middleware.AdminOnly,
			bonusController.GetAfiliasiBonuses)

		bonusGroup.POST("/:id/claim",
			middleware.VerifyUser,
			bonusController.ClaimBonus)

		bonusGroup.PATCH("/:id/transfer",
			middleware.VerifyUser,
			middleware.AdminOnly,
			bonusController.TransferBonus)

		bonusGroup.DELETE("/:id",
			middleware.VerifyUser,
			middleware.AdminOnly,
			bonusController.DeleteAfiliasiBonus)
	}
}
